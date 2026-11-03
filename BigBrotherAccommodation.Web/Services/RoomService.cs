using BigBrotherAccommodation.Web.Models;
using Supabase.Postgrest.Interfaces;

namespace BigBrotherAccommodation.Web.Services
{
    public class RoomService
    {
        private readonly IPostgrestClient _database;
        private readonly ILogger<RoomService> _logger;

        public RoomService(IPostgrestClient database, ILogger<RoomService> logger)
        {
            _database = database;
            _logger = logger;
        }

        public async Task<RoomListViewModel> GetRoomListAsync(string? search, string? roomType, string? price)
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

                var rooms = roomResult.Models.Where(r => r.IsAvailable && r.IsListed).OrderBy(r => r.Name).ToList();
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
                    Image = RoomPhotos.Cover(r, imageResult.Models.Where(i => i.RoomId == r.Id).Select(i => i.Image))
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load rooms from Supabase");
            }

            return model;
        }

        public async Task<RoomDetailsViewModel?> GetRoomDetailsAsync(Guid id)
        {
            try
            {
                var roomResult = await _database.Table<Room>().Get();
                var room = roomResult.Models.FirstOrDefault(r => r.Id == id);

                if (room == null)
                {
                    return null;
                }

                var imageResult = await _database.Table<RoomImage>().Get();

                var features = new List<string>();
                if (room.Wifi) features.Add("WiFi");
                if (room.Furniture) features.Add("Furnished");
                features.Add("Water & Electricity");
                features.Add("Safe Parking");
                if (room.Laundry) features.Add("Laundry");
                if (room.Security) features.Add("Security Camera");
                if (room.Shuttle) features.Add("Shuttle service");

                return new RoomDetailsViewModel
                {
                    Room = room,
                    Images = RoomPhotos.For(room, imageResult.Models.Where(i => i.RoomId == id).Select(i => i.Image)),
                    Features = features
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load room {RoomId}", id);
                return null;
            }
        }
    }
}