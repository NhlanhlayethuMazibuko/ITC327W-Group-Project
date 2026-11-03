using System.Security.Claims;
using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    [Authorize]
    public class ProfileController : Controller
    {
        private readonly ProfileService _profiles;
        private readonly ApplicationService _apps;
        private readonly AuthService _auth;

        public ProfileController(ProfileService profiles, ApplicationService apps, AuthService auth)
        {
            _profiles = profiles;
            _apps = apps;
            _auth = auth;
        }

        private bool TryGetStudent(out Guid studentId) =>
            Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out studentId);

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var model = new ProfileViewModel();
            var saved = await _profiles.GetAsync(studentId);

            if (saved != null)
            {
                model.FirstName = saved.FirstName;
                model.LastName = saved.LastName;
                model.Phone = saved.Phone;
                model.Institution = saved.Institution;
                model.StudentNumber = saved.StudentNumber;
            }
            else
            {
              
                var first = User.FindFirst("first_name")?.Value ?? "";
                if (first.Contains('@')) first = "";

                var full = User.FindFirst(ClaimTypes.Name)?.Value ?? "";
                var last = first != "" && full.StartsWith(first, StringComparison.OrdinalIgnoreCase)
                    ? full[first.Length..].Trim()
                    : "";

                var application = await _apps.GetLatestAsync(studentId) ?? await _apps.GetDraftAsync(studentId);

                model.FirstName = first;
                model.LastName = last;
                model.Phone = application?.Phone;
                model.Institution = application?.Institution;
            }

            model.Email = User.FindFirst(ClaimTypes.Email)?.Value ?? "";
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Index(ProfileViewModel model)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            model.Email = User.FindFirst(ClaimTypes.Email)?.Value ?? "";

            if (!ModelState.IsValid)
            {
                ViewData["Editing"] = true;
                return View(model);
            }

            if (!await _profiles.SaveAsync(studentId, model))
            {
                ModelState.AddModelError("", "We couldn't save your changes. Check the Output window in Visual Studio for the reason.");
                ViewData["Editing"] = true;
                return View(model);
            }

            var first = model.FirstName!.Trim();
            var last = model.LastName!.Trim();

            await _profiles.SyncNamesAsync(studentId, first, last);
            await RefreshSessionAsync(first, last);

            TempData["Message"] = "Your profile has been updated.";
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ChangePassword()
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value;

            if (!string.IsNullOrEmpty(email))
            {
                await _auth.SendResetEmailAsync(email,
                    Url.Action("ResetPassword", "Account", null, Request.Scheme)!);
            }

            TempData["Message"] = $"We’ve sent a reset code to {email}. Enter it below with your new password.";
            return RedirectToAction("ResetPassword", "Account", new { email });
        }

        // Updates the name in the login
        private async Task RefreshSessionAsync(string first, string last)
        {
            var scheme = CookieAuthenticationDefaults.AuthenticationScheme;
            var current = await HttpContext.AuthenticateAsync(scheme);

            var claims = User.Claims
                .Where(c => c.Type != "first_name" && c.Type != ClaimTypes.Name)
                .ToList();

            claims.Add(new Claim(ClaimTypes.Name, $"{first} {last}".Trim()));
            claims.Add(new Claim("first_name", first));

            await HttpContext.SignInAsync(scheme,
                new ClaimsPrincipal(new ClaimsIdentity(claims, scheme)),
                current.Properties);
        }
    }
}