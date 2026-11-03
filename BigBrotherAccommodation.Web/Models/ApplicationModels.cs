using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace BigBrotherAccommodation.Web.Models
{
    public class ApplicationRecord
    {
        [JsonPropertyName("application_id")] public Guid Id { get; set; }
        [JsonPropertyName("application_number")] public string Reference { get; set; } = "";
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("room_id")] public Guid? RoomId { get; set; }
        [JsonPropertyName("status_id")] public int StatusId { get; set; }
        [JsonPropertyName("application_date")] public DateTime? ApplicationDate { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset? CreatedAt { get; set; }
        [JsonPropertyName("staff_note")] public string? StaffNote { get; set; }

        [JsonIgnore] public string FullName { get; set; } = "";
        [JsonIgnore] public string Email { get; set; } = "";
        [JsonIgnore] public string Phone { get; set; } = "";
        [JsonIgnore] public string Institution { get; set; } = "";
        [JsonIgnore] public string PreferredRoom { get; set; } = "";
        [JsonIgnore] public string Status { get; set; } = "draft";
        [JsonIgnore] public decimal? AmountDue { get; set; }
        [JsonIgnore] public DateTime? PaymentDueDate { get; set; }
        [JsonIgnore] public DateTimeOffset? SubmittedAt => ApplicationDate.HasValue
            ? new DateTimeOffset(DateTime.SpecifyKind(ApplicationDate.Value, DateTimeKind.Utc))
            : null;
    }

    public class ApplicationDocument
    {
        [JsonPropertyName("document_id")] public Guid Id { get; set; }
        [JsonPropertyName("application_id")] public Guid ApplicationId { get; set; }
        [JsonPropertyName("document_type")] public string DocType { get; set; } = "";
        [JsonPropertyName("file_path")] public string FilePath { get; set; } = "";
        [JsonPropertyName("upload_date")] public DateTimeOffset? UploadDate { get; set; }
        [JsonIgnore] public string OriginalName { get; set; } = "";
    }

    public class PaymentRecord
    {
        [JsonPropertyName("payment_id")] public Guid Id { get; set; }
        [JsonPropertyName("payment_reference")] public string? PaymentReference { get; set; }
        [JsonPropertyName("application_id")] public Guid ApplicationId { get; set; }
        [JsonPropertyName("payment_method")] public string? PaymentMethod { get; set; }
        [JsonPropertyName("payment_status")] public string? PaymentStatus { get; set; }
        [JsonPropertyName("proof_of_payment")] public string? ProofOfPayment { get; set; }
        [JsonPropertyName("amount")] public decimal? Amount { get; set; }
        [JsonPropertyName("payment_date")] public DateTime? PaymentDate { get; set; }
        [JsonPropertyName("due_date")] public DateTime? DueDate { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset? CreatedAt { get; set; }

        [JsonIgnore] public string Reference => PaymentReference ?? "";
        [JsonIgnore] public string Method => PaymentMethod ?? "";
        [JsonIgnore] public string Status => PaymentStatus ?? "";
        [JsonIgnore] public string? ProofPath => ProofOfPayment;
        [JsonIgnore] public string? ProofName => ProofPath == null ? null : Path.GetFileName(ProofPath);
        [JsonIgnore] public decimal? AmountReported => Amount;
        [JsonIgnore] public DateTimeOffset? ReportedAt => PaymentDate.HasValue
            ? new DateTimeOffset(DateTime.SpecifyKind(PaymentDate.Value, DateTimeKind.Utc))
            : CreatedAt;
    }

    public class RoomLite
    {
        [JsonPropertyName("room_id")] public Guid Id { get; set; }
        [JsonPropertyName("room_name")] public string Name { get; set; } = "";
        [JsonPropertyName("room_type")] public string RoomType { get; set; } = "";
        [JsonPropertyName("price")] public decimal Price { get; set; }
    }

    public class ApplyDetailsViewModel
    {
        public Guid? RoomId { get; set; }

        [Required(ErrorMessage = "Enter your full name")]
        public string? FullName { get; set; }

        [Required(ErrorMessage = "Enter your email")]
        [EmailAddress(ErrorMessage = "Enter a valid email address")]
        public string? Email { get; set; }

        [Required(ErrorMessage = "Enter your phone number")]
        [RegularExpression(@"^\+?[0-9\s]{9,15}$", ErrorMessage = "Enter a valid phone number")]
        public string? Phone { get; set; }

        [Required(ErrorMessage = "Enter your institution or campus")]
        public string? Institution { get; set; }

        [Required(ErrorMessage = "Enter your preferred room")]
        public string? PreferredRoom { get; set; }
    }

    public class DocumentRow
    {
        public string Label { get; set; } = "";
        public string Hint { get; set; } = "";
        public string FieldName { get; set; } = "";
        public string? UploadedName { get; set; }
    }

    public class ApplyDocumentsViewModel
    {
        public List<DocumentRow> Rows { get; set; } = new();
        public List<string> Errors { get; set; } = new();
    }

    public class MyApplicationViewModel
    {
        public ApplicationRecord? App { get; set; }
        public ApplicationRecord? Draft { get; set; }
    }

    public class PaymentInstructionsViewModel
    {
        public ApplicationRecord App { get; set; } = new();
        public PaymentRecord? Payment { get; set; }
        public decimal? AmountValue { get; set; }
        public string AmountText { get; set; } = "";
        public string DueDateText { get; set; } = "";
        public string AccountHolder { get; set; } = "";
        public string BankName { get; set; } = "";
        public string AccountNumber { get; set; } = "";
        public string BranchCode { get; set; } = "";
    }

    public class PaymentSubmittedViewModel
    {
        public ApplicationRecord App { get; set; } = new();
        public PaymentRecord Payment { get; set; } = new();
        public string AmountText { get; set; } = "";
        public string ReportedOnText { get; set; } = "";
    }
}