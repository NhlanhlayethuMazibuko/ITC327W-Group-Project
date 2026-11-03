using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace BigBrotherAccommodation.Web.Models
{
    public class AdminDashboardViewModel
    {
        public int AvailableRooms { get; set; }
        public int OccupiedRooms { get; set; }
        public int ApplicationsToReview { get; set; }
        public int NewApplications { get; set; }
        public int ViewingRequests { get; set; }
    }

    public class AdminOccupant
    {
        public Guid ApplicationId { get; set; }
        public Guid StudentId { get; set; }
        public string Name { get; set; } = "";
        public string StudentNumber { get; set; } = "";
        public string Phone { get; set; } = "";
        public string Email { get; set; } = "";
        public string Institution { get; set; } = "";
        public string Application { get; set; } = "";
        public DateTimeOffset? Since { get; set; }
    }

    public class AdminRoomListViewModel
    {
        public List<Room> Rooms { get; set; } = new();
        public Dictionary<Guid, List<AdminOccupant>> Occupants { get; set; } = new();
        public string? Search { get; set; }
        public string? Availability { get; set; }
    }

    public class RoomFormViewModel
    {
        public Guid? Id { get; set; }

        [Required(ErrorMessage = "Enter a room name")]
        public string Name { get; set; } = "";

        [Required(ErrorMessage = "Select a room type")]
        public string RoomType { get; set; } = "";

        [Required(ErrorMessage = "Enter the monthly price")]
        [Range(1, 1000000, ErrorMessage = "Enter a valid price")]
        public decimal? Price { get; set; }

        public bool IsAvailable { get; set; } = true;

        public bool IsListed { get; set; } = true;

        [Required(ErrorMessage = "Select an occupancy type")]
        public string OccupancyType { get; set; } = "Single";

        public string? Description { get; set; }

        public List<string> RoomTypeOptions { get; set; } = new();
        public List<string> ExistingImages { get; set; } = new();
        public List<IFormFile> Photos { get; set; } = new();
    }

    public class AdminMaintenanceReportsViewModel
    {
        public List<AdminMaintenanceReportItem> Items { get; set; } = new();
        public bool LoadFailed { get; set; }
    }

    public class AdminMaintenanceReportItem
    {
        public AdminMaintenanceRow Record { get; set; } = new();
        public string StudentName { get; set; } = "";
        public string StudentNumber { get; set; } = "";
        public string Room { get; set; } = "";
    }

    public class AdminMaintenanceDetailViewModel
    {
        public AdminMaintenanceRow Record { get; set; } = new();
        public string StudentName { get; set; } = "";
        public string StudentNumber { get; set; } = "";
        public string Phone { get; set; } = "";
        public string Room { get; set; } = "";
        public string? PhotoUrl { get; set; }
        public List<MaintenanceUpdate> Updates { get; set; } = new();
        public AdminMaintenanceUpdateForm Form { get; set; } = new();
        public string? Error { get; set; }
    }

    public class AdminMaintenanceUpdateForm
    {
        public string? Status { get; set; }
        public string? Message { get; set; }
    }

    public class AdminPaymentsViewModel
    {
        public List<AdminPaymentItem> Items { get; set; } = new();
        public bool LoadFailed { get; set; }
    }

    public class AdminPaymentItem
    {
        public AdminPaymentRow Payment { get; set; } = new();
        public string StudentName { get; set; } = "";
        public string StudentNumber { get; set; } = "";
        public string Room { get; set; } = "";
    }

    public class AdminPaymentVerificationForm
    {
        [Required(ErrorMessage = "Choose an account verification result")]
        public string VerifiedAgainstAccount { get; set; } = "";

        [Range(0, 10000000, ErrorMessage = "Enter a valid verified amount")]
        public decimal? VerifiedAmount { get; set; }

        public DateTime? VerifiedDate { get; set; }
    }

    public class AdminAnnouncementsViewModel
    {
        public List<AdminAnnouncementRow> Items { get; set; } = new();
        public AdminAnnouncementForm NewAnnouncement { get; set; } = new();
        public bool LoadFailed { get; set; }
    }

    public class AdminAnnouncementDetailsViewModel
    {
        public AdminAnnouncementRow Announcement { get; set; } = new();
        public string Publisher { get; set; } = "";
    }

    public class AdminAnnouncementForm
    {
        [Required]
        [StringLength(120)]
        public string? Title { get; set; }

        [Required]
        [StringLength(5000)]
        public string? Message { get; set; }
    }
}