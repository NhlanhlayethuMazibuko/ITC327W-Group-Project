using System.Globalization;
using System.Security.Claims;
using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    [Authorize]
    public class NotificationsController : Controller
    {
        private readonly NotificationService _notifications;

        public NotificationsController(NotificationService notifications)
        {
            _notifications = notifications;
        }

        private bool TryGetStudent(out Guid studentId) =>
            Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out studentId);

        [HttpGet]
        public async Task<IActionResult> Index(string? filter)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var all = await _notifications.GetAsync(studentId);
            var unreadOnly = filter == "unread";

            var shown = unreadOnly ? all.Where(n => !n.IsRead).ToList() : all;
            var items = shown.Select(n => new NotificationItem
            {
                Record = n,
                TimeText = TimeText(n.CreatedAt)
            }).ToList();

            var model = new NotificationsViewModel
            {
                Filter = unreadOnly ? "unread" : "all",
                UnreadCount = all.Count(n => !n.IsRead),
                Today = items.Where(i => i.Record.CreatedAt.ToLocalTime().Date == DateTime.Today).ToList(),
                Earlier = items.Where(i => i.Record.CreatedAt.ToLocalTime().Date != DateTime.Today).ToList()
            };

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> MarkAllRead(string? filter)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            await _notifications.MarkAllReadAsync(studentId);
            return RedirectToAction("Index", new { filter });
        }

        // Marks one notification as read, then sends the user to the page it's linked to.
        [HttpGet]
        public async Task<IActionResult> Open(Guid id)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var notification = await _notifications.GetOneAsync(studentId, id);
            if (notification == null) return RedirectToAction("Index");

            await _notifications.MarkReadAsync(studentId, id);

            if (!string.IsNullOrEmpty(notification.LinkUrl) && Url.IsLocalUrl(notification.LinkUrl))
            {
                return LocalRedirect(notification.LinkUrl);
            }

            return RedirectToAction("Index");
        }

        private static string TimeText(DateTimeOffset created)
        {
            var local = created.ToLocalTime();
            var days = (DateTime.Today - local.Date).Days;

            if (days <= 0) return local.ToString("HH:mm", CultureInfo.InvariantCulture);
            if (days == 1) return "Yesterday";
            if (days < 7) return $"{days} days ago";
            return local.ToString("d MMM yyyy", CultureInfo.InvariantCulture);
        }
    }
}