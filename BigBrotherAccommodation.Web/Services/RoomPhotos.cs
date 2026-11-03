using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    // Bundled photos for rooms that have none uploaded yet, picked the same way
    // on every page so each room keeps its own pictures.
    public static class RoomPhotos
    {
        private static readonly string[] SingleBedrooms =
        {
            "/images/units/bedroom.jpg",
            "/images/units/bedroom3.jpg",
            "/images/units/bedroom4.jpg",
            "/images/units/bedroom6.jpg",
            "/images/units/bedroom7.jpg",
            "/images/rooms/single-room.jpg"
        };

        private static readonly string[] SharedBedrooms =
        {
            "/images/units/bedroom2.jpg",
            "/images/rooms/shared-room.jpg",
            "/images/rooms/2-bedroom-apartment.jpg"
        };

        private static readonly string[] Kitchens =
        {
            "/images/units/kitchen.jpg",
            "/images/units/kitchen2.jpg",
            "/images/units/kitchen3.jpg",
            "/images/units/kitchen4.jpg"
        };

        private static readonly string[] Bathrooms =
        {
            "/images/units/bathroom1.jpg",
            "/images/units/bathroom2.jpg",
            "/images/units/bathroom3.jpg",
            "/images/units/bathroom4.jpg",
            "/images/units/bathroom5.jpg",
            "/images/units/bathroom6.jpg"
        };

        private static readonly string[] Outside =
        {
            "/images/units/outside.jpg",
            "/images/units/outside2.jpg",
            "/images/units/outside3.jpg",
            "/images/units/outside4.jpg",
            "/images/units/outside5.jpg",
            "/images/units/outside6.jpg"
        };

        public static bool IsShared(Room room)
        {
            var text = $"{room.RoomType} {room.OccupancyType} {room.Name}".ToLowerInvariant();
            return text.Contains("shar") || text.Contains("2 bed") || text.Contains("2-bed") || text.Contains("double");
        }

        // Uploaded photos win; otherwise a bedroom, kitchen, bathroom and outside view.
        public static List<string> For(Room room, IEnumerable<string> uploaded)
        {
            var list = uploaded.Where(p => !string.IsNullOrWhiteSpace(p)).ToList();
            if (list.Count > 0) return list;

            var key = StableKey(room.Id);
            var bedrooms = IsShared(room) ? SharedBedrooms : SingleBedrooms;
            return new List<string>
            {
                bedrooms[key % bedrooms.Length],
                Kitchens[key % Kitchens.Length],
                Bathrooms[key % Bathrooms.Length],
                Outside[key % Outside.Length]
            };
        }

        public static string Cover(Room room, IEnumerable<string> uploaded) => For(room, uploaded)[0];

        private static int StableKey(Guid id)
        {
            unchecked
            {
                var h = 17;
                foreach (var c in id.ToString()) h = h * 31 + c;
                return h & 0x7fffffff;
            }
        }
    }
}
