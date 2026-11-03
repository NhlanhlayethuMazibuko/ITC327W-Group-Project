using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace BigBrotherAccommodation.Web.Models
{
    public class MaintenanceRecord
    {
        [JsonPropertyName("request_id")] public Guid Id { get; set; }
        [JsonPropertyName("reference_code")] public string Reference { get; set; } = "";
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("room_id")] public Guid? RoomId { get; set; }
        [JsonPropertyName("category")] public string Category { get; set; } = "";
        [JsonPropertyName("priority")] public string Priority { get; set; } = "routine";
        [JsonPropertyName("request_type")] public string Title { get; set; } = "";
        [JsonPropertyName("description")] public string Description { get; set; } = "";
        [JsonPropertyName("photo_path")] public string? PhotoPath { get; set; }
        [JsonPropertyName("status")] public string Status { get; set; } = "submitted";
        [JsonPropertyName("created_at")] public DateTimeOffset CreatedAt { get; set; }

        [JsonIgnore] public string RoomLabel { get; set; } = "";
        [JsonIgnore] public string? PhotoName { get; set; }

        [JsonIgnore]
        public string StatusLabel => MaintenanceRecord.LabelFor(Status);

        public static string LabelFor(string status) => status switch
        {
            "in_progress" => "In progress",
            "acknowledged" => "Acknowledged",
            "waiting" => "Waiting",
            "resolved" => "Resolved",
            "closed" => "Closed",
            _ => "Submitted"
        };
    }

    public class MaintenanceUpdate
    {
        [JsonPropertyName("update_id")] public Guid Id { get; set; }
        [JsonPropertyName("request_id")] public Guid MaintenanceId { get; set; }
        [JsonPropertyName("user_id")] public Guid? UserId { get; set; }
        [JsonPropertyName("status")] public string Status { get; set; } = "";
        [JsonPropertyName("message")] public string Message { get; set; } = "";
        [JsonPropertyName("created_at")] public DateTimeOffset CreatedAt { get; set; }

        [JsonIgnore]
        public string StatusLabel => MaintenanceRecord.LabelFor(Status);
    }

    public class MaintenanceFormViewModel
    {
        [Required(ErrorMessage = "Select a category")]
        public string? Category { get; set; }

        [Required(ErrorMessage = "Select a priority")]
        public string? Priority { get; set; }

        [Required(ErrorMessage = "Enter a short title")]
        [StringLength(80, ErrorMessage = "Keep the title under 80 characters")]
        public string? Title { get; set; }

        [Required(ErrorMessage = "Describe the issue")]
        [StringLength(1000, ErrorMessage = "Keep the description under 1000 characters")]
        public string? Description { get; set; }

        public List<string> Categories { get; set; } = new();
    }

    public class MaintenanceDetailsViewModel
    {
        public MaintenanceRecord Record { get; set; } = new();
        public List<MaintenanceUpdate> Updates { get; set; } = new();
    }
}