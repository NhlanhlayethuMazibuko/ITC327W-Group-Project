namespace BigBrotherAccommodation.Web.Models
{
    public class RoomCard
    {
        public Room Room { get; set; } = new();
        public string? Image { get; set; }
    }

    public class RoomListViewModel
    {
        public List<RoomCard> Rooms { get; set; } = new();
        public List<string> RoomTypes { get; set; } = new();
        public string? Search { get; set; }
        public string? SelectedType { get; set; }
        public string? SelectedPrice { get; set; }
    }

    public class RoomDetailsViewModel
    {
        public Room Room { get; set; } = new();
        public List<string> Images { get; set; } = new();
        public List<string> Features { get; set; } = new();
    }
}