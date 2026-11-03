using System.Text;
using System.Text.Json;
using Supabase;
using Supabase.Gotrue;

namespace BigBrotherAccommodation.Web.Services
{
    public record SignUpResult(bool Success, bool NeedsConfirmation, Session? Session, string? Error);

    public class AuthService
    {
        private readonly string _url;
        private readonly string _key;
        private readonly IHttpClientFactory _factory;
        private readonly ILogger<AuthService> _logger;

        public AuthService(IConfiguration config, IHttpClientFactory factory, ILogger<AuthService> logger)
        {
            _url = config["Supabase:Url"]!.TrimEnd('/');
            _key = config["Supabase:Key"]!;
            _factory = factory;
            _logger = logger;
        }

        private async Task<Supabase.Client> NewClientAsync()
        {
            var client = new Supabase.Client(_url, _key, new SupabaseOptions
            {
                AutoRefreshToken = false,
                AutoConnectRealtime = false
            });
            await client.InitializeAsync();
            return client;
        }

        public async Task<(Session? Session, bool NotConfirmed)> SignInAsync(string email, string password)
        {
            try
            {
                var client = await NewClientAsync();
                return (await client.Auth.SignIn(email, password), false);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Sign in failed");
                return (null, ex.Message.Contains("not confirmed") || ex.Message.Contains("email_not_confirmed"));
            }
        }

        public async Task<SignUpResult> SignUpAsync(string firstName, string lastName, string email, string password, string confirmUrl)
        {
            try
            {
                var client = await NewClientAsync();
                var session = await client.Auth.SignUp(email, password, new SignUpOptions
                {
                    RedirectTo = confirmUrl,
                    Data = new Dictionary<string, object>
                    {
                        { "first_name", firstName },
                        { "last_name", lastName }
                    }
                });

                if (session == null || string.IsNullOrEmpty(session.AccessToken))
                {
                    return new SignUpResult(true, true, null, null);
                }

                return new SignUpResult(true, false, session, null);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Sign up failed");
                return new SignUpResult(false, false, null, SignUpError(ex.Message));
            }
        }

        public async Task SendResetEmailAsync(string email, string resetUrl)
        {
            try
            {
                var req = new HttpRequestMessage(HttpMethod.Post,
                    $"{_url}/auth/v1/recover?redirect_to={Uri.EscapeDataString(resetUrl)}");
                req.Headers.Add("apikey", _key);
                req.Content = new StringContent(JsonSerializer.Serialize(new { email }), Encoding.UTF8, "application/json");

                using var res = await _factory.CreateClient().SendAsync(req);
                if (!res.IsSuccessStatusCode)
                {
                    _logger.LogWarning("Password reset email failed: {Status} {Body}",
                        (int)res.StatusCode, await res.Content.ReadAsStringAsync());
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Password reset email failed");
            }
        }

        // Checks a 6-digit email code ("signup" or "recovery").
        // Returns the session's access token, or an error message for the user.
        public async Task<(string? AccessToken, string? Error)> VerifyCodeAsync(string email, string code, string type)
        {
            try
            {
                var req = new HttpRequestMessage(HttpMethod.Post, $"{_url}/auth/v1/verify");
                req.Headers.Add("apikey", _key);
                req.Content = new StringContent(JsonSerializer.Serialize(new { type, email, token = code.Trim() }),
                    Encoding.UTF8, "application/json");

                using var res = await _factory.CreateClient().SendAsync(req);
                var body = await res.Content.ReadAsStringAsync();
                if (!res.IsSuccessStatusCode)
                {
                    _logger.LogWarning("Code check failed: {Status} {Body}", (int)res.StatusCode, body);
                    return (null, "That code is wrong or has expired. Check the latest email or request a new code.");
                }

                using var doc = JsonDocument.Parse(body);
                return (doc.RootElement.TryGetProperty("access_token", out var t) ? t.GetString() : null, null);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Code check failed");
                return (null, "We couldn't check the code. Please try again.");
            }
        }

        public async Task ResendSignupCodeAsync(string email)
        {
            try
            {
                var req = new HttpRequestMessage(HttpMethod.Post, $"{_url}/auth/v1/resend");
                req.Headers.Add("apikey", _key);
                req.Content = new StringContent(JsonSerializer.Serialize(new { type = "signup", email }), Encoding.UTF8, "application/json");
                using var res = await _factory.CreateClient().SendAsync(req);
                if (!res.IsSuccessStatusCode)
                {
                    _logger.LogWarning("Resend code failed: {Status}", (int)res.StatusCode);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Resend code failed");
            }
        }

        // Returns null on success, otherwise a message to show the user
        public async Task<string?> UpdatePasswordAsync(string accessToken, string newPassword)
        {
            try
            {
                var req = new HttpRequestMessage(HttpMethod.Put, $"{_url}/auth/v1/user");
                req.Headers.Add("apikey", _key);
                req.Headers.TryAddWithoutValidation("Authorization", "Bearer " + accessToken);
                req.Content = new StringContent(JsonSerializer.Serialize(new { password = newPassword }), Encoding.UTF8, "application/json");

                using var res = await _factory.CreateClient().SendAsync(req);
                if (res.IsSuccessStatusCode) return null;

                var body = await res.Content.ReadAsStringAsync();
                _logger.LogWarning("Password update failed: {Status} {Body}", (int)res.StatusCode, body);

                if (body.Contains("same_password") || body.Contains("should be different"))
                    return "Your new password must be different from your old one.";
                if (body.Contains("weak_password"))
                    return "That password is too weak. Try a longer one with letters and numbers.";
                if ((int)res.StatusCode == 401 || (int)res.StatusCode == 403)
                    return "This reset link has expired. Request a new one.";

                return "We couldn't update your password. Please try again.";
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Password update failed");
                return "We couldn't update your password. Please try again.";
            }
        }

        private static string SignUpError(string message)
        {
            if (message.Contains("already registered") || message.Contains("user_already_exists"))
                return "An account with this email already exists. Try signing in instead.";
            if (message.Contains("confirmation email"))
                return "We couldn't send your confirmation email right now. Please try again later.";
            if (message.Contains("rate limit") || message.Contains("over_email_send_rate_limit"))
                return "Too many attempts. Please wait a few minutes and try again.";
            if (message.Contains("weak_password") || message.Contains("Password should"))
                return "That password is too weak. Try a longer one with letters and numbers.";

            return "We couldn't create your account. Please check your details and try again.";
        }
    }
}
