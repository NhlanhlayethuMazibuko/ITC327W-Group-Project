using System.Globalization;
using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    public static class ViewingOptions
    {
        public static readonly string[] Times = { "09:00", "10:00", "11:00", "12:00", "14:00", "15:00", "16:00" };

        private const int DaysAhead = 14;

        public static List<SelectOption> Dates()
        {
            var list = new List<SelectOption>();

            for (var i = 1; i <= DaysAhead; i++)
            {
                var day = DateTime.Today.AddDays(i);
                if (day.DayOfWeek == DayOfWeek.Sunday) continue;

                list.Add(new SelectOption
                {
                    Value = day.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                    Label = day.ToString("dddd, d MMMM yyyy", CultureInfo.InvariantCulture)
                });
            }

            return list;
        }
    }

    public class ViewingService
    {
        private const string Table = "booking";

        private readonly SupabaseServer _db;
        private readonly ProfileService _profiles;
        private readonly ILogger<ViewingService> _logger;

        public ViewingService(SupabaseServer db, ProfileService profiles, ILogger<ViewingService> logger)
        {
            _db = db;
            _profiles = profiles;
            _logger = logger;
        }

        public async Task<ViewingRecord?> CreateAsync(Guid studentId, BookViewingViewModel m)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                var record = await _db.InsertAsync<ViewingRecord>(Table, new
                {
                    student_id = recordId,
                    room_id = m.RoomId,
                    reference_code = $"VIEW-{Guid.NewGuid():N}".ToUpperInvariant(),
                    booking_date = m.PreferredDate,
                    preferred_time = m.PreferredTime,
                    alternative_time = string.IsNullOrWhiteSpace(m.AlternativeTime) ? null : m.AlternativeTime,
                    message = string.IsNullOrWhiteSpace(m.Message) ? null : m.Message!.Trim(),
                    booking_status = "Requested"
                });
                if (record != null)
                {
                    record.Phone = (m.Phone ?? "").Trim();
                    await LoadRoomLabelsAsync(new[] { record });
                }
                return record;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not create viewing request");
                return null;
            }
        }

        public async Task<ViewingRecord?> GetAsync(Guid studentId, Guid id)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                var rows = await _db.SelectAsync<ViewingRecord>(Table, $"booking_id=eq.{id}&student_id=eq.{recordId}&limit=1");
                var record = rows.FirstOrDefault();
                if (record != null) await LoadRoomLabelsAsync(new[] { record });
                return record;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load viewing {Id}", id);
                return null;
            }
        }

        public async Task<List<ViewingRecord>> GetForStudentAsync(Guid studentId)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                var records = await _db.SelectAsync<ViewingRecord>(Table, $"student_id=eq.{recordId}&order=created_at.desc&limit=200");
                await LoadRoomLabelsAsync(records);
                return records;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load viewings");
                return new List<ViewingRecord>();
            }
        }

        public async Task<int> CountOpenAsync(Guid studentId)
        {
            try
            {
                var today = DateTime.Today;
                var records = await GetForStudentAsync(studentId);
                return records.Count(record =>
                    record.PreferredDate.Date >= today &&
                    (record.Status.Equals("requested", StringComparison.OrdinalIgnoreCase) ||
                     record.Status.Equals("confirmed", StringComparison.OrdinalIgnoreCase)));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not count viewings");
                return 0;
            }
        }

        public async Task<Dictionary<Guid, RoomLite>> GetRoomsAsync(IEnumerable<Guid> ids)
        {
            var list = ids.Distinct().ToList();
            if (list.Count == 0) return new Dictionary<Guid, RoomLite>();

            try
            {
                var rows = await _db.SelectAsync<RoomLite>("room",
                    $"room_id=in.({string.Join(",", list)})&select=room_id,room_name,room_type,price");
                return rows.ToDictionary(r => r.Id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load rooms for viewings");
                return new Dictionary<Guid, RoomLite>();
            }
        }

        public async Task<RoomLite?> GetRoomAsync(Guid roomId)
        {
            var rooms = await GetRoomsAsync(new[] { roomId });
            return rooms.TryGetValue(roomId, out var room) ? room : null;
        }

        private async Task LoadRoomLabelsAsync(IEnumerable<ViewingRecord> records)
        {
            var items = records.ToList();
            var rooms = await GetRoomsAsync(items.Where(r => r.RoomId.HasValue).Select(r => r.RoomId!.Value));

            foreach (var record in items)
            {
                record.Status = record.Status.ToLowerInvariant();
                if (record.RoomId.HasValue && rooms.TryGetValue(record.RoomId.Value, out var room))
                {
                    record.PreferredRoom = $"{room.Name} - {room.RoomType}";
                }
            }
        }
    }
}