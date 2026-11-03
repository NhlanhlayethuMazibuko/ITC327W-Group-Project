using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace BigBrotherAccommodation.Web.Services
{
    public class SupabaseServer
    {
        private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

        private readonly IHttpClientFactory _factory;
        private readonly ILogger<SupabaseServer> _logger;
        private readonly string _url;
        private readonly string _key;

        public SupabaseServer(IHttpClientFactory factory, IConfiguration config, ILogger<SupabaseServer> logger)
        {
            _factory = factory;
            _logger = logger;
            _url = (config["Supabase:Url"] ?? "").TrimEnd('/');
            _key = config["Supabase:ServiceKey"] ?? "";
        }

        public async Task<List<T>> SelectAsync<T>(string table, string query)
        {
            using var res = await SendAsync(HttpMethod.Get, $"/rest/v1/{table}?{query}", null, null);
            var text = await ReadAsync(res, "select " + table);
            return JsonSerializer.Deserialize<List<T>>(text, JsonOptions) ?? new List<T>();
        }

        public async Task<T?> InsertAsync<T>(string table, object row)
        {
            using var res = await SendAsync(HttpMethod.Post, $"/rest/v1/{table}", Json(row), "return=representation");
            var text = await ReadAsync(res, "insert " + table);
            var rows = JsonSerializer.Deserialize<List<T>>(text, JsonOptions);
            return rows != null && rows.Count > 0 ? rows[0] : default;
        }

        public async Task UpdateAsync(string table, string filter, object changes)
        {
            using var res = await SendAsync(HttpMethod.Patch, $"/rest/v1/{table}?{filter}", Json(changes), "return=minimal");
            await ReadAsync(res, "update " + table);
        }

        public async Task DeleteAsync(string table, string filter)
        {
            using var res = await SendAsync(HttpMethod.Delete, $"/rest/v1/{table}?{filter}", null, "return=minimal");
            await ReadAsync(res, "delete from " + table);
        }

        public async Task UpsertAsync(string table, string onConflict, object row)
        {
            using var res = await SendAsync(HttpMethod.Post, $"/rest/v1/{table}?on_conflict={onConflict}", Json(row),
                "resolution=merge-duplicates,return=minimal");
            await ReadAsync(res, "upsert " + table);
        }

        public async Task UploadAsync(string bucket, string path, byte[] bytes, string contentType)
        {
            var content = new ByteArrayContent(bytes);
            content.Headers.ContentType = new MediaTypeHeaderValue(contentType);
            using var res = await SendAsync(HttpMethod.Post, $"/storage/v1/object/{bucket}/{path}", content, null);
            await ReadAsync(res, "upload to " + bucket);
        }

        // A temporary link to a file in a private bucket, or null if it can't be made
        public async Task<string?> SignedUrlAsync(string bucket, string path, int seconds = 3600)
        {
            try
            {
                using var res = await SendAsync(HttpMethod.Post, $"/storage/v1/object/sign/{bucket}/{path}",
                    Json(new { expiresIn = seconds }), null);
                var text = await ReadAsync(res, "sign " + bucket);
                using var doc = JsonDocument.Parse(text);
                var signed = doc.RootElement.GetProperty("signedURL").GetString();
                return signed == null ? null : _url + "/storage/v1" + signed;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not sign {Path} in {Bucket}", path, bucket);
                return null;
            }
        }

        public async Task DeleteObjectAsync(string bucket, string path)
        {
            try
            {
                using var res = await SendAsync(HttpMethod.Delete, $"/storage/v1/object/{bucket}/{path}", null, null);
                if (!res.IsSuccessStatusCode)
                {
                    _logger.LogWarning("Could not delete {Path} from {Bucket}: {Status}", path, bucket, (int)res.StatusCode);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not delete {Path} from {Bucket}", path, bucket);
            }
        }

        private async Task<HttpResponseMessage> SendAsync(HttpMethod method, string path, HttpContent? content, string? prefer)
        {
            if (string.IsNullOrEmpty(_url) || string.IsNullOrEmpty(_key))
            {
                throw new InvalidOperationException("Supabase:Url or Supabase:ServiceKey is missing from user secrets.");
            }

            var req = new HttpRequestMessage(method, _url + path);
            req.Headers.Add("apikey", _key);

            if (_key.StartsWith("eyJ"))
            {
                req.Headers.TryAddWithoutValidation("Authorization", "Bearer " + _key);
            }

            if (prefer != null)
            {
                req.Headers.TryAddWithoutValidation("Prefer", prefer);
            }

            req.Content = content;
            return await _factory.CreateClient().SendAsync(req);
        }

        private static async Task<string> ReadAsync(HttpResponseMessage res, string action)
        {
            var text = await res.Content.ReadAsStringAsync();
            if (!res.IsSuccessStatusCode)
            {
                throw new HttpRequestException($"Supabase {action} failed: {(int)res.StatusCode} {text}");
            }
            return text;
        }

        private static StringContent Json(object value) =>
            new(JsonSerializer.Serialize(value), Encoding.UTF8, "application/json");
    }
}