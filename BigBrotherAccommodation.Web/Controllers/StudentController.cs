using System.Security.Claims;
using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    [Authorize]
    public class StudentController : Controller
    {
        private readonly RoomService _rooms;
        private readonly ApplicationService _applications;

        public StudentController(RoomService rooms, ApplicationService applications)
        {
            _rooms = rooms;
            _applications = applications;
        }

        public async Task<IActionResult> Dashboard()
        {
            var list = await _rooms.GetRoomListAsync(null, null, null);

            var name = User.FindFirst("first_name")?.Value;
            if (string.IsNullOrWhiteSpace(name) || name.Contains('@'))
            {
                name = "Student";
            }

            string? status = null;
            if (Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out var studentId))
            {
                var latest = await _applications.GetLatestAsync(studentId);
                status = latest?.Status;
            }

            var model = new StudentDashboardViewModel
            {
                FirstName = name,
                ApplicationStatus = status,
                FeaturedRooms = list.Rooms.Take(3).ToList()
            };

            return View(model);
        }

        public async Task<IActionResult> Rooms(string? search, string? roomType, string? price)
        {
            var model = await _rooms.GetRoomListAsync(search, roomType, price);
            return View(model);
        }

        public async Task<IActionResult> RoomDetails(Guid id)
        {
            var model = await _rooms.GetRoomDetailsAsync(id);

            if (model == null)
            {
                return NotFound();
            }

            return View(model);
        }
    }
}