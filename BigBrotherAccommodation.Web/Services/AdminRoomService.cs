using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using BigBrotherAccommodation.Web.Models;
using Supabase.Postgrest.Interfaces;

namespace BigBrotherAccommodation.Web.Services
{
    public class AdminRoomService
    {
        private const string Bucket = "room-images";
        private const long MaxPhotoBytes = 5 * 1024 * 1024;
        private static readonly string[] AllowedTypes = { "image/jpeg", "image/png", "image/webp" };

        private readonly IHttpClientFactory _httpFactory;
        private readonly IPostgrestClient _database;
        private readonly ILogger<AdminRoomService> _logger;
        private readonly string _url;
        private readonly string _serviceKey;

        public AdminRoomService(IHttpClientFactory httpFactory, IPostgrestClient database,
            IConfiguration config, ILogger<AdminRoomService> logger)
        {
            _httpFactory = httpFactory;
            _database = database;
            _logger = logger;
            _url = (config["Supabase:Url"] ?? "").TrimEnd('/');
            _serviceKey = config["Supabase:ServiceKey"] ?? "";
        }

        // Reading

        public async Task<List<Room>> GetAllRoomsAsync()
        {
            try
            {
                var result = await _database.Table<Room>().Get();
                return result.Models.OrderBy(r => r.Name).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load rooms");
                return new List<Room>();
            }
        }

        public async Task<Room?> GetRoomAsync(Guid id)
        {
            var rooms = await GetAllRoomsAsync();
            return rooms.FirstOrDefault(r => r.Id == id);
        }

        public async Task<List<string>> GetImagesAsync(Guid roomId)
        {
            try
            {
                var result = await _database.Table<RoomImage>().Get();
                return result.Models.Where(i => i.RoomId == roomId).Select(i => i.Image).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load images for room {RoomId}", roomId);
                return new List<string>();
            }
        }

        // Writing

        public async Task<Guid?> CreateRoomAsync(RoomFormViewModel m)
        {
            try
            {
                var body = JsonSerializer.Serialize(new
                {
                    room_name = m.Name.Trim(),
                    room_type = m.RoomType,
                    price = m.Price,
                    availability_status = m.IsAvailable,
                    is_listed = m.IsListed,
                    occupancy_type = m.OccupancyType,
                    description = string.IsNullOrWhiteSpace(m.Description) ? null : m.Description.Trim(),
                    wifi = true,
                    laundry = true,
                    security = true,
                    shuttle = true,
                    furniture = true
                });

                using var res = await SendAsync(HttpMethod.Post, "/rest/v1/room", Json(body), true);
                if (res == null) return null;

                var text = await res.Content.ReadAsStringAsync();
                if (!res.IsSuccessStatusCode)
                {
                    _logger.LogError("Create room failed: {Status} {Body}", (int)res.StatusCode, text);
                    return null;
                }

                using var doc = JsonDocument.Parse(text);
                return doc.RootElement[0].GetProperty("room_id").GetGuid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Create room failed");
                return null;
            }
        }

        public async Task<bool> UpdateRoomAsync(RoomFormViewModel m)
        {
            try
            {
                var body = JsonSerializer.Serialize(new
                {
                    room_name = m.Name.Trim(),
                    room_type = m.RoomType,
                    price = m.Price,
                    availability_status = m.IsAvailable,
                    is_listed = m.IsListed,
                    occupancy_type = m.OccupancyType,
                    description = string.IsNullOrWhiteSpace(m.Description) ? null : m.Description.Trim()
                });

                using var res = await SendAsync(HttpMethod.Patch, $"/rest/v1/room?room_id=eq.{m.Id}", Json(body));
                return await CheckAsync(res, "Update room");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Update room failed");
                return false;
            }
        }

        public async Task<bool> SetAvailabilityAsync(Guid id, bool available)
        {
            try
            {
                var body = JsonSerializer.Serialize(new { availability_status = available });
                using var res = await SendAsync(HttpMethod.Patch, $"/rest/v1/room?room_id=eq.{id}", Json(body));
                return await CheckAsync(res, "Set availability");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Set availability failed");
                return false;
            }
        }

        public async Task<(int Added, int Skipped)> AddPhotosAsync(Guid roomId, IEnumerable<IFormFile> files)
        {
            var rows = new List<object>();
            var skipped = 0;

            foreach (var file in files)
            {
                if (file.Length == 0) continue;

                if (!AllowedTypes.Contains(file.ContentType) || file.Length > MaxPhotoBytes)
                {
                    skipped++;
                    continue;
                }

                var ext = file.ContentType switch
                {
                    "image/png" => ".png",
                    "image/webp" => ".webp",
                    _ => ".jpg"
                };
                var path = $"{roomId}/{Guid.NewGuid():N}{ext}";

                try
                {
                    using var ms = new MemoryStream();
                    await file.CopyToAsync(ms);
                    var content = new ByteArrayContent(ms.ToArray());
                    content.Headers.ContentType = new MediaTypeHeaderValue(file.ContentType);

                    using var res = await SendAsync(HttpMethod.Post, $"/storage/v1/object/{Bucket}/{path}", content);
                    if (await CheckAsync(res, "Upload photo"))
                    {
                        rows.Add(new { room_id = roomId, image_path = $"{_url}/storage/v1/object/public/{Bucket}/{path}" });
                    }
                    else
                    {
                        skipped++;
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Photo upload failed");
                    skipped++;
                }
            }

            if (rows.Count == 0) return (0, skipped);

            try
            {
                using var res = await SendAsync(HttpMethod.Post, "/rest/v1/room_image", Json(JsonSerializer.Serialize(rows)));
                if (await CheckAsync(res, "Save photo rows")) return (rows.Count, skipped);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Saving photo rows failed");
            }

            return (0, skipped + rows.Count);
        }

        //  Helpers 

        private async Task<HttpResponseMessage?> SendAsync(HttpMethod method, string path, HttpContent? content, bool returnBody = false)
        {
            if (string.IsNullOrEmpty(_serviceKey))
            {
                _logger.LogError("Supabase:ServiceKey is missing from user secrets");
                return null;
            }

            var http = _httpFactory.CreateClient();
            using var req = new HttpRequestMessage(method, _url + path);
            req.Headers.Add("apikey", _serviceKey);

            if (_serviceKey.StartsWith("eyJ"))
            {
                req.Headers.TryAddWithoutValidation("Authorization", "Bearer " + _serviceKey);
            }

            if (returnBody)
            {
                req.Headers.Add("Prefer", "return=representation");
            }

            req.Content = content;
            return await http.SendAsync(req);
        }

        private async Task<bool> CheckAsync(HttpResponseMessage? res, string action)
        {
            if (res == null) return false;
            if (res.IsSuccessStatusCode) return true;

            var text = await res.Content.ReadAsStringAsync();
            _logger.LogError("{Action} failed: {Status} {Body}", action, (int)res.StatusCode, text);
            return false;
        }

        private static StringContent Json(string json) => new(json, Encoding.UTF8, "application/json");
    }
}