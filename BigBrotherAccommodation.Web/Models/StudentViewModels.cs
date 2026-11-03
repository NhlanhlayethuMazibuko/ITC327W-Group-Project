namespace BigBrotherAccommodation.Web.Models
{
    public class StudentDashboardViewModel
    {
        public string FirstName { get; set; } = "";

        // "review" shows the "under review" banner
        public string? ApplicationStatus { get; set; }

        public List<RoomCard> FeaturedRooms { get; set; } = new();
    }
}