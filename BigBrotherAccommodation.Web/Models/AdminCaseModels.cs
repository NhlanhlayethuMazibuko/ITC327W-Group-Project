using System.Text.Json.Serialization;

namespace BigBrotherAccommodation.Web.Models
{
    // ---- Database rows (match your ERD tables) ----

    public class AdminApplicationRow
    {
        [JsonPropertyName("application_id")] public Guid Id { get; set; }
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("room_id")] public Guid? RoomId { get; set; }
        [JsonPropertyName("status_id")] public int StatusId { get; set; }
        [JsonPropertyName("application_number")] public string? ApplicationNumber { get; set; }
        [JsonPropertyName("application_date")] public DateTime? ApplicationDate { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset? CreatedAt { get; set; }
        [JsonPropertyName("staff_note")] public string? StaffNote { get; set; }
    }

    public class AdminStudentRow
    {
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("user_id")] public Guid? UserId { get; set; }
        [JsonPropertyName("full_name")] public string? FullName { get; set; }
        [JsonPropertyName("student_number")] public string? StudentNumber { get; set; }
        [JsonPropertyName("phone_number")] public string? PhoneNumber { get; set; }
        [JsonPropertyName("institution")] public string? Institution { get; set; }
    }

    public class AdminBookingRow
    {
        [JsonPropertyName("booking_id")] public Guid Id { get; set; }
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("room_id")] public Guid? RoomId { get; set; }
        [JsonPropertyName("reference_code")] public string? ReferenceCode { get; set; }
        [JsonPropertyName("booking_date")] public DateTime? BookingDate { get; set; }
        [JsonPropertyName("preferred_time")] public string? PreferredTime { get; set; }
        [JsonPropertyName("alternative_time")] public string? AlternativeTime { get; set; }
        [JsonPropertyName("booking_status")] public string? BookingStatus { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset? CreatedAt { get; set; }
        [JsonPropertyName("message")] public string? Message { get; set; }
        [JsonPropertyName("staff_alt_date")] public DateTime? StaffAltDate { get; set; }
        [JsonPropertyName("staff_alt_time")] public string? StaffAltTime { get; set; }
        [JsonPropertyName("staff_message")] public string? StaffMessage { get; set; }
        [JsonPropertyName("responded_at")] public DateTimeOffset? RespondedAt { get; set; }
    }

    // ---- Forms ----

    public class ApplicationStageForm
    {
        public string? Stage { get; set; }      // submitted | reviewing | decision
        public string? Outcome { get; set; }    // approved | rejected (only for a decision)
        public string? Note { get; set; }
    }

    public class ViewingResponseForm
    {
        public string? Response { get; set; }   // confirm | alternative | decline
        public string? AltDate { get; set; }    // yyyy-MM-dd
        public string? AltTime { get; set; }
        public string? Message { get; set; }
    }

    // ---- Applications ----

    public class AdminApplicationListItem
    {
        public Guid Id { get; set; }
        public string Reference { get; set; } = "";
        public string Student { get; set; } = "";
        public string Room { get; set; } = "";
        public string SubmittedText { get; set; } = "";
        public long SortKey { get; set; }
        public string StageKey { get; set; } = "";
        public string StageLabel { get; set; } = "";
        public string SearchText { get; set; } = "";
    }

    public class AdminApplicationsViewModel
    {
        public List<AdminApplicationListItem> Items { get; set; } = new();
        public bool LoadFailed { get; set; }
    }

    public class AdminApplicationReviewViewModel
    {
        public Guid Id { get; set; }
        public string Reference { get; set; } = "";
        public string SubmittedText { get; set; } = "";
        public string StageKey { get; set; } = "";
        public string StageLabel { get; set; } = "";
        public string OutcomeLabel { get; set; } = "";
        public string Name { get; set; } = "";
        public string Email { get; set; } = "";
        public string Phone { get; set; } = "";
        public string Institution { get; set; } = "";
        public string StudentNumber { get; set; } = "";
        public string Room { get; set; } = "";
        public ApplicationStageForm Form { get; set; } = new();
        public string? Error { get; set; }
    }

    // ---- Viewings ----

    public class AdminViewingListItem
    {
        public Guid Id { get; set; }
        public string Reference { get; set; } = "";
        public string Student { get; set; } = "";
        public string Room { get; set; } = "";
        public string RequestedText { get; set; } = "";
        public long SortKey { get; set; }
        public string StatusKey { get; set; } = "";
        public string StatusLabel { get; set; } = "";
        public string SearchText { get; set; } = "";
    }

    public class AdminViewingsViewModel
    {
        public List<AdminViewingListItem> Items { get; set; } = new();
        public bool LoadFailed { get; set; }
    }

    public class HistoryLine
    {
        public string Event { get; set; } = "";
        public string Channel { get; set; } = "";
        public string DateText { get; set; } = "";
        public string Status { get; set; } = "";
    }

    public class AdminViewingDetailViewModel
    {
        public Guid Id { get; set; }
        public string Reference { get; set; } = "";
        public string Student { get; set; } = "";
        public string Email { get; set; } = "";
        public string Phone { get; set; } = "";
        public string StatusKey { get; set; } = "";
        public string StatusLabel { get; set; } = "";
        public string Room { get; set; } = "";
        public string StudentMessage { get; set; } = "";
        public string RequestedText { get; set; } = "";
        public ViewingResponseForm Form { get; set; } = new();
        public List<SelectOption> Dates { get; set; } = new();
        public List<string> Times { get; set; } = new();
        public List<HistoryLine> History { get; set; } = new();
        public string? Error { get; set; }
    }

    // ---- Student records ----

    public class AdminStudentListItem
    {
        public Guid StudentId { get; set; }
        public string Name { get; set; } = "";
        public string Status { get; set; } = "";
        public string Room { get; set; } = "";
        public string RecordKey { get; set; } = "";     // applicant | occupant
        public string RecordLabel { get; set; } = "";
        public string SearchText { get; set; } = "";
    }

    public class AdminStudentsViewModel
    {
        public List<AdminStudentListItem> Items { get; set; } = new();
        public bool LoadFailed { get; set; }
    }

    public class RecordApplicationLine
    {
        public Guid Id { get; set; }
        public string Reference { get; set; } = "";
        public string Room { get; set; } = "";
        public string SubmittedText { get; set; } = "";
        public string Outcome { get; set; } = "";
    }

    public class RecordViewingLine
    {
        public Guid Id { get; set; }
        public string Reference { get; set; } = "";
        public string Room { get; set; } = "";
        public string DateText { get; set; } = "";
        public string Status { get; set; } = "";
    }

    public class AdminStudentRecordViewModel
    {
        public Guid StudentId { get; set; }
        public string Name { get; set; } = "";
        public string Initial { get; set; } = "";
        public string Email { get; set; } = "";
        public string Phone { get; set; } = "";
        public string Institution { get; set; } = "";
        public string StudentNumber { get; set; } = "";
        public string Room { get; set; } = "";
        public string BadgeLabel { get; set; } = "";
        public string Occupancy { get; set; } = "";
        public List<RecordApplicationLine> Applications { get; set; } = new();
        public List<RecordViewingLine> Viewings { get; set; } = new();
    }
}