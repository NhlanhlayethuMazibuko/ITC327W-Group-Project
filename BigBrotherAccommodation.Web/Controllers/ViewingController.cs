using System.Globalization;
using System.Security.Claims;
using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    [Authorize]
    public class ViewingController : Controller
    {
        private const int MaxOpenViewings = 3;

        private readonly ViewingService _viewings;
        private readonly NotificationService _notifications;

        private readonly ApplicationService _apps;

        // Tenants already have a room, so they don't book viewings
        private async Task<IActionResult?> BlockTenantAsync(Guid studentId)
        {
            if (!await _apps.IsTenantAsync(studentId)) return null;
            TempData["Message"] = "You're already a tenant, so you can't book a viewing. Contact management if you plan to move out.";
            return RedirectToAction("Mine");
        }

        public ViewingController(ViewingService viewings, NotificationService notifications, ApplicationService apps)
        {
            _viewings = viewings;
            _notifications = notifications;
            _apps = apps;
        }

        private bool TryGetStudent(out Guid studentId) =>
            Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out studentId);

        private static void FillOptions(BookViewingViewModel model)
        {
            model.Dates = ViewingOptions.Dates();
            model.Times = ViewingOptions.Times.ToList();
        }

        // Book a viewing

        [HttpGet]
        public async Task<IActionResult> Book(Guid? roomId)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();
            if (await BlockTenantAsync(studentId) is { } blocked) return blocked;

            var model = new BookViewingViewModel();
            FillOptions(model);

            if (roomId.HasValue)
            {
                var room = await _viewings.GetRoomAsync(roomId.Value);
                if (room != null)
                {
                    model.RoomId = room.Id;
                    model.PreferredRoom = $"{room.Name} - {room.RoomType}";
                }
            }

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Book(BookViewingViewModel model)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();
            if (await BlockTenantAsync(studentId) is { } blocked) return blocked;

            FillOptions(model);

            if (!string.IsNullOrEmpty(model.PreferredDate) && model.Dates.All(d => d.Value != model.PreferredDate))
            {
                ModelState.AddModelError(nameof(model.PreferredDate), "Choose a date from the list");
            }

            if (!string.IsNullOrEmpty(model.PreferredTime) && !model.Times.Contains(model.PreferredTime))
            {
                ModelState.AddModelError(nameof(model.PreferredTime), "Choose a time from the list");
            }

            if (!string.IsNullOrEmpty(model.AlternativeTime) &&
                (!model.Times.Contains(model.AlternativeTime) || model.AlternativeTime == model.PreferredTime))
            {
                ModelState.AddModelError(nameof(model.AlternativeTime), "Choose a different time from the list");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            if (await _viewings.CountOpenAsync(studentId) >= MaxOpenViewings)
            {
                ModelState.AddModelError("", $"You already have {MaxOpenViewings} upcoming viewings. Please wait for one to finish before booking another.");
                return View(model);
            }

            var viewing = await _viewings.CreateAsync(studentId, model);
            if (viewing == null)
            {
                ModelState.AddModelError("", "We couldn't send your viewing request. Check the Output window in Visual Studio for the reason.");
                return View(model);
            }

            await _notifications.AddAsync(studentId, "Viewing request received",
                $"Your viewing request for {viewing.PreferredRoom} on {viewing.PreferredDate.ToString("d MMMM yyyy", CultureInfo.InvariantCulture)} at {viewing.PreferredTime} has been sent. We will confirm it shortly.",
                "/Viewing/Mine", "View my viewings");

            return RedirectToAction("Submitted", new { id = viewing.Id });
        }

        // Request submitted 

        [HttpGet]
        public async Task<IActionResult> Submitted(Guid id)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var viewing = await _viewings.GetAsync(studentId, id);
            if (viewing == null) return NotFound();

            return View(viewing);
        }

        // ---------- My viewings ----------

        [HttpGet]
        public async Task<IActionResult> Mine(string? tab)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var all = await _viewings.GetForStudentAsync(studentId);
            var today = DateTime.Today;

            bool IsUpcoming(ViewingRecord v) =>
                (v.Status == "requested" || v.Status == "confirmed") && v.PreferredDate.Date >= today;

            var rooms = await _viewings.GetRoomsAsync(
                all.Where(v => v.RoomId.HasValue).Select(v => v.RoomId!.Value));

            ViewingCard ToCard(ViewingRecord v) => new ViewingCard
            {
                Viewing = v,
                Room = v.RoomId.HasValue && rooms.TryGetValue(v.RoomId.Value, out var room) ? room : null
            };

            var model = new MyViewingsViewModel
            {
                Tab = tab == "past" ? "past" : "upcoming",
                Upcoming = all.Where(IsUpcoming)
                    .OrderBy(v => v.PreferredDate).ThenBy(v => v.PreferredTime)
                    .Select(ToCard).ToList(),
                Past = all.Where(v => !IsUpcoming(v))
                    .OrderByDescending(v => v.PreferredDate)
                    .Select(ToCard).ToList()
            };

            return View(model);
        }
    }
}