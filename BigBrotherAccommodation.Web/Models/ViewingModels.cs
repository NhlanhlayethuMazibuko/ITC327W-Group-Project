using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace BigBrotherAccommodation.Web.Models
{
    public class ViewingRecord
    {
        [JsonPropertyName("booking_id")] public Guid Id { get; set; }
        [JsonPropertyName("reference_code")] public string Reference { get; set; } = "";
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("room_id")] public Guid? RoomId { get; set; }
        [JsonPropertyName("booking_date")] public DateTime PreferredDate { get; set; }
        [JsonPropertyName("preferred_time")] public string PreferredTime { get; set; } = "";
        [JsonPropertyName("alternative_time")] public string? AlternativeTime { get; set; }
        [JsonPropertyName("message")] public string? Message { get; set; }
        [JsonPropertyName("booking_status")] public string Status { get; set; } = "requested";
        [JsonPropertyName("created_at")] public DateTimeOffset CreatedAt { get; set; }

        [JsonIgnore] public string PreferredRoom { get; set; } = "";
        [JsonIgnore] public string Phone { get; set; } = "";
    }

    public class NotificationRecord
    {
        [JsonPropertyName("notification_id")] public Guid Id { get; set; }
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("title")] public string Title { get; set; } = "";
        [JsonPropertyName("message")] public string Message { get; set; } = "";
        [JsonPropertyName("notification_type")] public string? NotificationType { get; set; }
        [JsonPropertyName("is_read")] public bool IsRead { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset CreatedAt { get; set; }

        [JsonIgnore] public string? LinkUrl { get; set; }
        [JsonIgnore] public string? LinkText { get; set; }
    }

    public class SelectOption
    {
        public string Value { get; set; } = "";
        public string Label { get; set; } = "";
    }

    public class BookViewingViewModel
    {
        public Guid? RoomId { get; set; }

        [Required(ErrorMessage = "Select a date")]
        public string? PreferredDate { get; set; }

        [Required(ErrorMessage = "Choose a time")]
        public string? PreferredTime { get; set; }

        public string? AlternativeTime { get; set; }

        [Required(ErrorMessage = "Enter your phone number")]
        [RegularExpression(@"^\+?[0-9\s]{9,15}$", ErrorMessage = "Enter a valid phone number")]
        public string? Phone { get; set; }

        [StringLength(500, ErrorMessage = "Keep your message under 500 characters")]
        public string? Message { get; set; }

        [Required(ErrorMessage = "Enter your preferred room")]
        public string? PreferredRoom { get; set; }

        public List<SelectOption> Dates { get; set; } = new();
        public List<string> Times { get; set; } = new();
    }

    public class ViewingCard
    {
        public ViewingRecord Viewing { get; set; } = new();
        public RoomLite? Room { get; set; }
    }

    public class MyViewingsViewModel
    {
        public string Tab { get; set; } = "upcoming";
        public List<ViewingCard> Upcoming { get; set; } = new();
        public List<ViewingCard> Past { get; set; } = new();
    }

    public class NotificationItem
    {
        public NotificationRecord Record { get; set; } = new();
        public string TimeText { get; set; } = "";
    }

    public class NotificationsViewModel
    {
        public string Filter { get; set; } = "all";
        public int UnreadCount { get; set; }
        public List<NotificationItem> Today { get; set; } = new();
        public List<NotificationItem> Earlier { get; set; } = new();
    }
}