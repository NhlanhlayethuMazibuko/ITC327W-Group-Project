using System.Security.Claims;
using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    public class AccountController : Controller
    {
        private readonly AuthService _auth;

        public AccountController(AuthService auth)
        {
            _auth = auth;
        }

        // Sign in 

        [HttpGet]
        public IActionResult SignIn(string? returnUrl = null, bool confirmed = false)
        {
            if (User.Identity?.IsAuthenticated == true)
            {
                return User.IsInRole("admin")
                    ? RedirectToAction("Dashboard", "Admin")
                    : RedirectToAction("Dashboard", "Student");
            }

            if (confirmed)
            {
                TempData["Message"] = "Your email is confirmed. You can sign in now.";
            }

            return View(new SignInViewModel { ReturnUrl = returnUrl });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SignIn(SignInViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var (session, notConfirmed) = await _auth.SignInAsync(model.Email.Trim(), model.Password);

            if (notConfirmed)
            {
                await _auth.ResendSignupCodeAsync(model.Email.Trim());
                return RedirectToAction("VerifyEmail", new { email = model.Email.Trim() });
            }

            if (session?.User == null)
            {
                ModelState.AddModelError("", "Incorrect email or password.");
                return View(model);
            }

            var role = await StartSessionAsync(session.User, model.RememberMe);
            return RedirectAfterSignIn(model.ReturnUrl, role);
        }

        // Create account 

        [HttpGet]
        public IActionResult SignUp()
        {
            if (User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Dashboard", "Student");
            }

            return View(new SignUpViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SignUp(SignUpViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = await _auth.SignUpAsync(
                model.FirstName.Trim(), model.LastName.Trim(), model.Email.Trim(), model.Password,
                Url.Action("SignIn", "Account", new { confirmed = true }, Request.Scheme)!);

            if (!result.Success)
            {
                ModelState.AddModelError("", result.Error ?? "Something went wrong. Please try again.");
                return View(model);
            }

            if (result.NeedsConfirmation)
            {
                return RedirectToAction("VerifyEmail", new { email = model.Email.Trim() });
            }

            TempData["Message"] = "Account created. Please sign in with your email and password.";
            return RedirectToAction("SignIn");
        }

        // Verify email with the code Supabase emails (same code the app uses)

        [HttpGet]
        public IActionResult VerifyEmail(string? email)
        {
            return View(new VerifyEmailViewModel { Email = email ?? "" });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> VerifyEmail(VerifyEmailViewModel model, string? resend)
        {
            if (resend != null)
            {
                ModelState.Remove(nameof(model.Code));
                if (!ModelState.IsValid) return View(model);
                await _auth.ResendSignupCodeAsync(model.Email.Trim());
                ViewData["Notice"] = "We've sent a new code. Use the code in the newest email.";
                return View(model);
            }

            if (!ModelState.IsValid) return View(model);

            var (_, error) = await _auth.VerifyCodeAsync(model.Email.Trim(), model.Code, "signup");
            if (error != null)
            {
                ModelState.AddModelError("", error);
                return View(model);
            }

            TempData["Message"] = "Your email is confirmed. You can sign in now.";
            return RedirectToAction("SignIn");
        }

        // Forgot password 

        [HttpGet]
        public IActionResult ForgotPassword()
        {
            return View(new ForgotPasswordViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            await _auth.SendResetEmailAsync(model.Email.Trim(),
                Url.Action("ResetPassword", "Account", null, Request.Scheme)!);

            TempData["Message"] = "If an account exists for that email, we've sent a reset code. Enter it below.";
            return RedirectToAction("ResetPassword", new { email = model.Email.Trim() });
        }

        // Reset password: code from the email (or an older emailed link) + new password

        [HttpGet]
        public IActionResult ResetPassword(string? email)
        {
            return View(new ResetPasswordViewModel { Email = email });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ResetPassword(ResetPasswordViewModel model)
        {
            if (string.IsNullOrEmpty(model.AccessToken) &&
                (string.IsNullOrWhiteSpace(model.Email) || string.IsNullOrWhiteSpace(model.Code)))
            {
                ModelState.AddModelError("", "Enter your email and the code we sent you.");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var accessToken = model.AccessToken;
            if (string.IsNullOrEmpty(accessToken))
            {
                var (token, codeError) = await _auth.VerifyCodeAsync(model.Email!.Trim(), model.Code!, "recovery");
                if (token == null)
                {
                    ModelState.AddModelError("", codeError ?? "That code is wrong or has expired.");
                    return View(model);
                }
                accessToken = token;
            }

            var error = await _auth.UpdatePasswordAsync(accessToken, model.Password);
            if (error != null)
            {
                ModelState.AddModelError("", error);
                return View(model);
            }

            TempData["Message"] = "Your password has been updated. Sign in with your new password.";
            return RedirectToAction("SignIn");
        }

        // Sign out 

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> LogOut()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public IActionResult Continue()
        {
            return View();
        }

        //  Helpers 

        private async Task<string> StartSessionAsync(Supabase.Gotrue.User user, bool remember)
        {
            var first = MetaValue(user, "first_name");
            var last = MetaValue(user, "last_name");
            var fullName = $"{first} {last}".Trim();
            // Accounts made in the Flutter app may only carry full_name
            if (fullName == "") fullName = MetaValue(user, "full_name").Trim();
            if (first == "" && fullName != "") first = fullName.Split(' ')[0];
            if (fullName == "") fullName = user.Email ?? "Student";

            var role = AppMetaValue(user, "user_role") == "admin" ? "admin" : "student";

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.Id ?? ""),
                new(ClaimTypes.Email, user.Email ?? ""),
                new(ClaimTypes.Name, fullName),
                new("first_name", first == "" ? fullName : first),
                new(ClaimTypes.Role, role)
            };

            var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(identity),
                new AuthenticationProperties { IsPersistent = remember });

            return role;
        }

        private static string MetaValue(Supabase.Gotrue.User user, string key)
        {
            if (user.UserMetadata != null && user.UserMetadata.TryGetValue(key, out var value))
            {
                return value?.ToString() ?? "";
            }
            return "";
        }

        private static string AppMetaValue(Supabase.Gotrue.User user, string key)
        {
            if (user.AppMetadata != null && user.AppMetadata.TryGetValue(key, out var value))
            {
                return value?.ToString() ?? "";
            }
            return "";
        }

        private IActionResult RedirectAfterSignIn(string? returnUrl, string role = "student")
        {
            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                return LocalRedirect(returnUrl);
            }

            return role == "admin"
                ? RedirectToAction("Dashboard", "Admin")
                : RedirectToAction("Dashboard", "Student");
        }
    }
}