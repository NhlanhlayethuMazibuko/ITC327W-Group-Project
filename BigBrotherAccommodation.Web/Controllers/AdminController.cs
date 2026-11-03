using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BigBrotherAccommodation.Web.Controllers
{
    [Authorize(Roles = "admin")]
    public class AdminController : Controller
    {
        private readonly AdminRoomService _rooms;
        private readonly AdminCaseService _cases;
        private readonly AdminReportsService _reports;

        public AdminController(AdminRoomService rooms, AdminCaseService cases, AdminReportsService reports)
        {
            _rooms = rooms;
            _cases = cases;
            _reports = reports;
        }

        // Dashboard

        public async Task<IActionResult> Dashboard()
        {
            var rooms = await _rooms.GetAllRoomsAsync();
            var open = await _cases.CountOpenAsync();

            return View(new AdminDashboardViewModel
            {
                AvailableRooms = rooms.Count(r => r.IsAvailable),
                OccupiedRooms = rooms.Count(r => !r.IsAvailable),
                ApplicationsToReview = open.Applications,
                NewApplications = open.NewApplications,
                ViewingRequests = open.Viewings
            });
        }

        // Applications

        public async Task<IActionResult> Applications()
        {
            return View(await _cases.GetApplicationsAsync());
        }

        [HttpGet]
        public async Task<IActionResult> ApplicationReview(Guid id)
        {
            var model = await _cases.GetApplicationReviewAsync(id);
            if (model == null)
            {
                return NotFound();
            }

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ApplicationReview(Guid id, ApplicationStageForm form)
        {
            var error = await _cases.UpdateApplicationAsync(id, form);

            if (error != null)
            {
                var model = await _cases.GetApplicationReviewAsync(id);
                if (model == null)
                {
                    return NotFound();
                }

                model.Form = form;
                model.Error = error;
                return View(model);
            }

            TempData["Message"] = "Application updated.";
            return RedirectToAction("Applications");
        }

        // Viewing requests

        public async Task<IActionResult> Viewings()
        {
            return View(await _cases.GetViewingsAsync());
        }

        [HttpGet]
        public async Task<IActionResult> ViewingDetails(Guid id)
        {
            var model = await _cases.GetViewingDetailAsync(id);
            if (model == null)
            {
                return NotFound();
            }

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ViewingDetails(Guid id, ViewingResponseForm form)
        {
            var error = await _cases.RespondToViewingAsync(id, form);

            if (error != null)
            {
                var model = await _cases.GetViewingDetailAsync(id);
                if (model == null)
                {
                    return NotFound();
                }

                model.Form = form;
                model.Error = error;
                return View(model);
            }

            TempData["Message"] = "Viewing request updated.";
            return RedirectToAction("Viewings");
        }

        // Student records

        public async Task<IActionResult> Maintenance()
        {
            return View(await _reports.GetMaintenanceAsync());
        }

        [HttpGet]
        public async Task<IActionResult> MaintenanceDetails(Guid id)
        {
            var model = await _reports.GetMaintenanceDetailAsync(id);
            return model == null ? NotFound() : View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> MaintenanceDetails(Guid id, AdminMaintenanceUpdateForm form)
        {
            Guid? staffId = Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var parsed) ? parsed : null;
            var error = await _reports.UpdateMaintenanceAsync(id, form, staffId);

            if (error != null)
            {
                var model = await _reports.GetMaintenanceDetailAsync(id);
                if (model == null) return NotFound();
                model.Form = form;
                model.Error = error;
                return View(model);
            }

            TempData["Message"] = "Maintenance request updated and the student was notified.";
            return RedirectToAction("MaintenanceDetails", new { id });
        }

        public async Task<IActionResult> Announcements()
        {
            return View(await _reports.GetAnnouncementsAsync());
        }

        [HttpGet]
        public async Task<IActionResult> AnnouncementDetails(Guid id)
        {
            var model = await _reports.GetAnnouncementAsync(id);
            return model == null ? NotFound() : View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateAnnouncement([Bind(Prefix = "NewAnnouncement")] AdminAnnouncementForm form)
        {
            var model = await _reports.GetAnnouncementsAsync();
            model.NewAnnouncement = form;

            if (!ModelState.IsValid)
            {
                return View("Announcements", model);
            }

            Guid? userId = Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var parsedUserId)
                ? parsedUserId
                : null;

            if (!await _reports.CreateAnnouncementAsync(userId, form))
            {
                ModelState.AddModelError("", "The announcement could not be saved to Supabase.");
                return View("Announcements", model);
            }

            TempData["Message"] = "Announcement published and sent to all students.";
            return RedirectToAction(nameof(Announcements));
        }

        public async Task<IActionResult> Payments()
        {
            return View(await _reports.GetPaymentsAsync());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SavePaymentVerification(Guid id, AdminPaymentVerificationForm form)
        {
            if (!ModelState.IsValid)
            {
                TempData["Error"] = "Enter a valid payment verification result.";
                return RedirectToAction(nameof(Payments));
            }

            var error = await _reports.SavePaymentVerificationAsync(id, form);
            TempData[error == null ? "Message" : "Error"] = error ?? "Payment verification saved.";
            return RedirectToAction(nameof(Payments));
        }

        public async Task<IActionResult> Students()
        {
            return View(await _cases.GetStudentsAsync());
        }

        public async Task<IActionResult> StudentRecord(Guid id)
        {
            var model = await _cases.GetStudentRecordAsync(id);
            if (model == null)
            {
                return NotFound();
            }

            return View(model);
        }

        // Properties & rooms

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RemoveTenant(Guid applicationId)
        {
            var error = await _cases.MoveOutAsync(applicationId);
            TempData["Message"] = error ?? "Tenant removed. The room is free again and the student was notified.";
            return RedirectToAction("Rooms");
        }

        public async Task<IActionResult> Rooms(string? search, string? availability)
        {
            var rooms = await _rooms.GetAllRoomsAsync();
            var occupants = await _cases.GetOccupantsAsync();

            if (!string.IsNullOrWhiteSpace(search))
            {
                rooms = rooms.Where(r =>
                    r.Name.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                    r.RoomType.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                    (r.CurrentOccupant ?? "").Contains(search, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            if (availability == "available")
            {
                rooms = rooms.Where(r => r.IsAvailable).ToList();
            }
            else if (availability == "occupied")
            {
                rooms = rooms.Where(r => !r.IsAvailable).ToList();
            }

            return View(new AdminRoomListViewModel
            {
                Rooms = rooms,
                Occupants = occupants,
                Search = search,
                Availability = availability
            });
        }

        // Add room

        [HttpGet]
        public async Task<IActionResult> AddRoom()
        {
            return View(new RoomFormViewModel { RoomTypeOptions = await TypeOptionsAsync() });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AddRoom(RoomFormViewModel model)
        {
            model.RoomTypeOptions = await TypeOptionsAsync();

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var id = await _rooms.CreateRoomAsync(model);
            if (id == null)
            {
                ModelState.AddModelError("", "We couldn't save the room. Check the Output window in Visual Studio for the reason.");
                return View(model);
            }

            var (_, skipped) = await _rooms.AddPhotosAsync(id.Value, model.Photos);

            TempData["Message"] = skipped > 0
                ? $"Room saved. {skipped} photo(s) could not be uploaded (JPG, PNG or WebP under 5 MB only)."
                : "Room saved.";

            return RedirectToAction("Rooms");
        }

        // Edit room

        [HttpGet]
        public async Task<IActionResult> EditRoom(Guid id)
        {
            var room = await _rooms.GetRoomAsync(id);
            if (room == null)
            {
                return NotFound();
            }

            var model = new RoomFormViewModel
            {
                Id = room.Id,
                Name = room.Name,
                RoomType = room.RoomType,
                Price = room.Price,
                IsAvailable = room.IsAvailable,
                IsListed = room.IsListed,
                OccupancyType = string.IsNullOrWhiteSpace(room.OccupancyType) ? "Single" : room.OccupancyType,
                Description = room.Description,
                RoomTypeOptions = await TypeOptionsAsync(),
                ExistingImages = await _rooms.GetImagesAsync(room.Id)
            };

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditRoom(Guid id, RoomFormViewModel model)
        {
            model.Id = id;
            model.RoomTypeOptions = await TypeOptionsAsync();
            model.ExistingImages = await _rooms.GetImagesAsync(id);

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            if (!await _rooms.UpdateRoomAsync(model))
            {
                ModelState.AddModelError("", "We couldn't save your changes. Check the Output window in Visual Studio for the reason.");
                return View(model);
            }

            var (_, skipped) = await _rooms.AddPhotosAsync(id, model.Photos);

            TempData["Message"] = skipped > 0
                ? $"Changes saved. {skipped} photo(s) could not be uploaded (JPG, PNG or WebP under 5 MB only)."
                : "Changes saved.";

            return RedirectToAction("Rooms");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> MarkUnavailable(Guid id)
        {
            var ok = await _rooms.SetAvailabilityAsync(id, false);
            TempData["Message"] = ok ? "Room marked as unavailable." : "We couldn't update the room.";
            return RedirectToAction("Rooms");
        }

        // Helpers

        private async Task<List<string>> TypeOptionsAsync()
        {
            var defaults = new[] { "Single room", "Sharing room", "1-Bedroom Apartment", "2-Bedroom Apartment", "Single with Balcony" };
            var existing = (await _rooms.GetAllRoomsAsync()).Select(r => r.RoomType);

            return defaults.Concat(existing)
                .Where(t => !string.IsNullOrWhiteSpace(t))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(t => t)
                .ToList();
        }
    }
}