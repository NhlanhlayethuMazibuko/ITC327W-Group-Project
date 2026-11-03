using System.Security.Claims;
using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    [Authorize]
    public class MaintenanceController : Controller
    {
        private readonly MaintenanceService _maintenance;
        private readonly NotificationService _notifications;

        public MaintenanceController(MaintenanceService maintenance, NotificationService notifications)
        {
            _maintenance = maintenance;
            _notifications = notifications;
        }

        private bool TryGetStudent(out Guid studentId) =>
            Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out studentId);

        // Maintenance is for tenants: students whose application has been approved
        private IActionResult NotTenant()
        {
            TempData["Message"] = "Maintenance requests open once your application has been approved and you are a tenant.";
            return RedirectToAction("Index");
        }

        // My maintenance requests

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            ViewBag.IsTenant = await _maintenance.GetCurrentRoomIdAsync(studentId) != null;
            return View(await _maintenance.GetListAsync(studentId));
        }

        // Request detail

        [HttpGet]
        public async Task<IActionResult> Details(Guid id)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var record = await _maintenance.GetAsync(studentId, id);
            if (record == null) return NotFound();

            return View(new MaintenanceDetailsViewModel
            {
                Record = record,
                Updates = await _maintenance.GetUpdatesAsync(record.Id)
            });
        }

        // Report an issue

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            if (!TryGetStudent(out var studentId)) return Challenge();
            if (await _maintenance.GetCurrentRoomIdAsync(studentId) == null) return NotTenant();

            return View(new MaintenanceFormViewModel { Categories = MaintenanceOptions.Categories.ToList() });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [RequestSizeLimit(10_000_000)]
        public async Task<IActionResult> Create(MaintenanceFormViewModel model, IFormFile? photo)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            model.Categories = MaintenanceOptions.Categories.ToList();

            if (!string.IsNullOrEmpty(model.Category) && !model.Categories.Contains(model.Category))
            {
                ModelState.AddModelError(nameof(model.Category), "Choose a category from the list");
            }

            if (!string.IsNullOrEmpty(model.Priority) && model.Priority != "routine" && model.Priority != "urgent")
            {
                ModelState.AddModelError(nameof(model.Priority), "Choose Routine or Urgent");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var roomId = await _maintenance.GetCurrentRoomIdAsync(studentId);
            if (roomId == null) return NotTenant();

            var (record, error) = await _maintenance.CreateAsync(studentId, roomId, model, photo);
            if (record == null)
            {
                ModelState.AddModelError("", error ?? "We couldn't save your request. Please try again.");
                return View(model);
            }

            await _notifications.AddAsync(studentId, "Maintenance request received",
                $"Your report \"{record.Title}\" ({record.Reference}) has been sent to management.",
                $"/Maintenance/Details/{record.Id}", "View request");

            return RedirectToAction("Submitted", new { id = record.Id });
        }

        // Request submitted

        [HttpGet]
        public async Task<IActionResult> Submitted(Guid id)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var record = await _maintenance.GetAsync(studentId, id);
            if (record == null) return NotFound();

            return View(record);
        }
    }
}