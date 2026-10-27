using BigBrotherAccommodation.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Supabase.Postgrest.Interfaces;

namespace BigBrotherAccommodation.Web.Controllers
{
    public class RoomsController : Controller
    {
        private readonly ILogger<RoomsController> _logger;
        private readonly IPostgrestClient _database;

        public RoomsController(ILogger<RoomsController> logger, IPostgrestClient database)
        {
            _logger = logger;
            _database = database;
        }

        public async Task<IActionResult> Index(string? search, string? roomType, string? price)
        {
            var model = new RoomListViewModel
            {
                Search = search,
                SelectedType = roomType,
                SelectedPrice = price
            };

            try
            {
                var roomResult = await _database.Table<Room>().Get();
                var imageResult = await _database.Table<RoomImage>().Get();

                var rooms = roomResult.Models.Where(r => r.IsAvailable).ToList();
                model.RoomTypes = rooms.Select(r => r.RoomType).Distinct().OrderBy(t => t).ToList();

                if (!string.IsNullOrWhiteSpace(search))
                {
                    rooms = rooms.Where(r =>
                        r.Name.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                        r.RoomType.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                        (r.Description ?? "").Contains(search, StringComparison.OrdinalIgnoreCase)).ToList();
                }

                if (!string.IsNullOrWhiteSpace(roomType))
                {
                    rooms = rooms.Where(r => r.RoomType == roomType).ToList();
                }

                rooms = price switch
                {
                    "low" => rooms.Where(r => r.Price < 4500).ToList(),
                    "mid" => rooms.Where(r => r.Price >= 4500 && r.Price <= 6000).ToList(),
                    "high" => rooms.Where(r => r.Price > 6000).ToList(),
                    _ => rooms
                };

                model.Rooms = rooms.Select(r => new RoomCard
                {
                    Room = r,
                    Image = imageResult.Models.FirstOrDefault(i => i.RoomId == r.Id)?.Image
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load rooms from Supabase");
            }

            return View(model);
        }

        public async Task<IActionResult> Details(Guid id)
        {
            try
            {
                var roomResult = await _database.Table<Room>().Get();
                var room = roomResult.Models.FirstOrDefault(r => r.Id == id);

                if (room == null)
                {
                    return NotFound();
                }

                var imageResult = await _database.Table<RoomImage>().Get();

                // water, electricity and parking are the same for the whole property (see the FAQ)
                var features = new List<string>();
                if (room.Wifi) features.Add("WiFi");
                if (room.Furniture) features.Add("Furnished");
                features.Add("Water & Electricity");
                if (room.Laundry) features.Add("Laundry");
                features.Add("Safe Parking");
                if (room.Security) features.Add("CCTV Security");
                if (room.Shuttle) features.Add("Shuttle service");

                var model = new RoomDetailsViewModel
                {
                    Room = room,
                    Images = imageResult.Models.Where(i => i.RoomId == id).Select(i => i.Image).ToList(),
                    Features = features
                };

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load room {RoomId}", id);
                return NotFound();
            }
        }
    }
}