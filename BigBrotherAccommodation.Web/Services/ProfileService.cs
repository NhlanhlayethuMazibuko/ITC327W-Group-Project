using System.Text;
using System.Text.Json;
using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    public class ProfileService
    {
        private const string Table = "student";

        private readonly SupabaseServer _db;
        private readonly IHttpClientFactory _factory;
        private readonly IConfiguration _config;
        private readonly ILogger<ProfileService> _logger;

        public ProfileService(SupabaseServer db, IHttpClientFactory factory, IConfiguration config, ILogger<ProfileService> logger)
        {
            _db = db;
            _factory = factory;
            _config = config;
            _logger = logger;
        }

        public async Task<ProfileRecord?> GetAsync(Guid studentId)
        {
            try
            {
                var rows = await _db.SelectAsync<ProfileRecord>(Table, $"user_id=eq.{studentId}&limit=1");
                if (rows.Count > 0) return rows[0];

                rows = await _db.SelectAsync<ProfileRecord>(Table, $"student_id=eq.{studentId}&limit=1");
                return rows.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load profile");
                return null;
            }
        }

        public async Task<Guid> ResolveStudentIdAsync(Guid userId)
        {
            var profile = await GetAsync(userId);
            if (profile != null)
            {
                if (profile.UserId != userId)
                {
                    await _db.UpsertAsync(Table, "student_id", new
                    {
                        student_id = profile.StudentId,
                        user_id = userId
                    });
                }

                return profile.StudentId;
            }

            await _db.UpsertAsync(Table, "student_id", new
            {
                student_id = userId,
                user_id = userId
            });
            return userId;
        }

        public async Task<bool> SaveAsync(Guid studentId, ProfileViewModel m)
        {
            try
            {
                var profile = await GetAsync(studentId);
                var recordId = profile?.StudentId ?? studentId;

                await _db.UpsertAsync(Table, "student_id", new
                {
                    student_id = recordId,
                    user_id = studentId,
                    full_name = $"{m.FirstName!.Trim()} {m.LastName!.Trim()}".Trim(),
                    phone_number = (m.Phone ?? "").Trim(),
                    institution = (m.Institution ?? "").Trim(),
                    student_number = (m.StudentNumber ?? "").Trim()
                });
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not save profile");
                return false;
            }
        }

        public async Task SyncNamesAsync(Guid studentId, string firstName, string lastName)
        {
            try
            {
                var url = (_config["Supabase:Url"] ?? "").TrimEnd('/');
                var key = (_config["Supabase:ServiceKey"] ?? "").Trim().Trim('"');
                if (url == "" || key == "") return;

                using var req = new HttpRequestMessage(HttpMethod.Put, $"{url}/auth/v1/admin/users/{studentId}");
                req.Headers.Add("apikey", key);

                if (key.StartsWith("eyJ"))
                {
                    req.Headers.TryAddWithoutValidation("Authorization", "Bearer " + key);
                }

                var body = JsonSerializer.Serialize(new
                {
                    user_metadata = new { first_name = firstName, last_name = lastName }
                });
                req.Content = new StringContent(body, Encoding.UTF8, "application/json");

                using var res = await _factory.CreateClient().SendAsync(req);
                if (!res.IsSuccessStatusCode)
                {
                    _logger.LogWarning("Could not sync names to the login: {Status} {Body}",
                        (int)res.StatusCode, await res.Content.ReadAsStringAsync());
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not sync names to the login");
            }
        }
    }
}