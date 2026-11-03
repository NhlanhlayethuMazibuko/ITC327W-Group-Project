using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    public static class MaintenanceOptions
    {
        public static readonly string[] Categories =
        {
            "Plumbing", "Electrical", "Furniture", "Appliances", "Doors and windows",
            "Pests", "Internet / WiFi", "Cleaning", "Other"
        };
    }

    public class MaintenanceService
    {
        private const string Table = "maintenance_requests";
        private const string UpdateTable = "maintenance_update";
        public const string PhotoBucket = "maintenance-photos";
        private const long MaxPhotoBytes = 5 * 1024 * 1024;

        private record PhotoCheck(byte[]? Bytes, string ContentType, string Ext, string? Error);
        private class StudentRoomApplication
        {
            [System.Text.Json.Serialization.JsonPropertyName("room_id")]
            public Guid? RoomId { get; set; }
        }

        private readonly SupabaseServer _db;
        private readonly ProfileService _profiles;
        private readonly ILogger<MaintenanceService> _logger;

        public MaintenanceService(SupabaseServer db, ProfileService profiles, ILogger<MaintenanceService> logger)
        {
            _db = db;
            _profiles = profiles;
            _logger = logger;
        }

        public async Task<Guid?> GetCurrentRoomIdAsync(Guid studentId)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                var applications = await _db.SelectAsync<StudentRoomApplication>(
                    "application", $"student_id=eq.{recordId}&status_id=eq.3&select=room_id&order=created_at.desc&limit=1");
                return applications.FirstOrDefault()?.RoomId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load the student's current room");
                return null;
            }
        }

        public async Task<(MaintenanceRecord? Record, string? Error)> CreateAsync(
            Guid studentId, Guid? roomId, MaintenanceFormViewModel m, IFormFile? photo)
        {
            try
            {
                var recordStudentId = await _profiles.ResolveStudentIdAsync(studentId);
                string? path = null;

                if (photo != null && photo.Length > 0)
                {
                    var check = await ReadPhotoAsync(photo);
                    if (check.Error != null) return (null, check.Error);

                    path = $"{recordStudentId}/{Guid.NewGuid():N}{check.Ext}";
                    await _db.UploadAsync(PhotoBucket, path, check.Bytes!, check.ContentType);
                }

                var record = await _db.InsertAsync<MaintenanceRecord>(Table, new
                {
                    student_id = recordStudentId,
                    room_id = roomId,
                    reference_code = $"MNT-{Guid.NewGuid():N}".ToUpperInvariant(),
                    category = m.Category,
                    priority = m.Priority,
                    request_type = m.Title!.Trim(),
                    description = m.Description!.Trim(),
                    photo_path = path,
                    status = "submitted"
                });

                if (record == null) return (null, "We couldn't save your request. Please try again.");

                try
                {
                    await _db.InsertAsync<MaintenanceUpdate>(UpdateTable, new
                    {
                        request_id = record.Id,
                        user_id = studentId,
                        status = "submitted",
                        message = "Request received by management"
                    });
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Could not add the first update");
                }

                record.PhotoName = photo == null ? null : SafeName(photo.FileName);
                await LoadRoomLabelAsync(record);
                return (record, null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not create maintenance request");
                return (null, "We couldn't save your request. Check the Output window in Visual Studio for the reason.");
            }
        }

        public async Task<List<MaintenanceRecord>> GetListAsync(Guid studentId)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                var records = await _db.SelectAsync<MaintenanceRecord>(Table, $"student_id=eq.{recordId}&order=created_at.desc&limit=200");
                await LoadRoomLabelsAsync(records);
                return records;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load maintenance requests");
                return new List<MaintenanceRecord>();
            }
        }

        public async Task<MaintenanceRecord?> GetAsync(Guid studentId, Guid id)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                var rows = await _db.SelectAsync<MaintenanceRecord>(Table, $"request_id=eq.{id}&student_id=eq.{recordId}&limit=1");
                var record = rows.FirstOrDefault();
                if (record != null) await LoadRoomLabelAsync(record);
                return record;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load maintenance request {Id}", id);
                return null;
            }
        }

        public async Task<List<MaintenanceUpdate>> GetUpdatesAsync(Guid maintenanceId)
        {
            try
            {
                return await _db.SelectAsync<MaintenanceUpdate>(UpdateTable, $"request_id=eq.{maintenanceId}&order=created_at.asc");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load updates");
                return new List<MaintenanceUpdate>();
            }
        }

        private async Task LoadRoomLabelsAsync(List<MaintenanceRecord> records)
        {
            var ids = records.Where(r => r.RoomId.HasValue).Select(r => r.RoomId!.Value).Distinct().ToList();
            if (ids.Count == 0) return;

            var rooms = await _db.SelectAsync<RoomLite>(
                "room", $"room_id=in.({string.Join(",", ids)})&select=room_id,room_name,room_type,price");
            var roomMap = rooms.ToDictionary(room => room.Id);

            foreach (var record in records)
            {
                if (record.RoomId.HasValue && roomMap.TryGetValue(record.RoomId.Value, out var room))
                {
                    record.RoomLabel = room.Name;
                }
            }
        }

        private async Task LoadRoomLabelAsync(MaintenanceRecord record)
        {
            if (record.RoomId.HasValue)
            {
                await LoadRoomLabelsAsync(new List<MaintenanceRecord> { record });
            }
        }

        private static async Task<PhotoCheck> ReadPhotoAsync(IFormFile file)
        {
            var name = SafeName(file.FileName);
            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();

            var contentType = ext switch
            {
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                _ => ""
            };

            if (contentType == "") return new PhotoCheck(null, "", "", $"{name}: only JPG or PNG photos are accepted.");
            if (file.Length > MaxPhotoBytes) return new PhotoCheck(null, "", "", $"{name} is larger than 5 MB.");

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            var bytes = ms.ToArray();

            var valid = contentType == "image/jpeg"
                ? bytes.Length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF
                : bytes.Length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;

            if (!valid) return new PhotoCheck(null, "", "", $"{name} doesn't look like a valid photo. Please choose another.");

            return new PhotoCheck(bytes, contentType, ext == ".jpeg" ? ".jpg" : ext, null);
        }

        private static string SafeName(string fileName)
        {
            var name = Path.GetFileName(fileName);
            name = new string(name.Where(c => !char.IsControl(c)).ToArray());
            return name.Length > 120 ? name[..120] : name;
        }
    }
}