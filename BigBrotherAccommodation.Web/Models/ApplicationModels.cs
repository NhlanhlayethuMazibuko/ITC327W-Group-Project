using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace BigBrotherAccommodation.Web.Models
{
    public class ApplicationRecord
    {
        [JsonPropertyName("application_id")] public Guid Id { get; set; }
        [JsonPropertyName("reference")] public string Reference { get; set; } = "";
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("room_id")] public Guid? RoomId { get; set; }
        [JsonPropertyName("full_name")] public string FullName { get; set; } = "";
        [JsonPropertyName("email")] public string Email { get; set; } = "";
        [JsonPropertyName("phone")] public string Phone { get; set; } = "";
        [JsonPropertyName("institution")] public string Institution { get; set; } = "";
        [JsonPropertyName("preferred_room")] public string PreferredRoom { get; set; } = "";
        [JsonPropertyName("status")] public string Status { get; set; } = "draft";
        [JsonPropertyName("amount_due")] public decimal? AmountDue { get; set; }
        [JsonPropertyName("payment_due_date")] public DateTime? PaymentDueDate { get; set; }
        [JsonPropertyName("submitted_at")] public DateTimeOffset? SubmittedAt { get; set; }
    }

    public class ApplicationDocument
    {
        [JsonPropertyName("document_id")] public Guid Id { get; set; }
        [JsonPropertyName("application_id")] public Guid ApplicationId { get; set; }
        [JsonPropertyName("doc_type")] public string DocType { get; set; } = "";
        [JsonPropertyName("file_path")] public string FilePath { get; set; } = "";
        [JsonPropertyName("original_name")] public string OriginalName { get; set; } = "";
    }

    public class PaymentRecord
    {
        [JsonPropertyName("payment_id")] public Guid Id { get; set; }
        [JsonPropertyName("reference")] public string Reference { get; set; } = "";
        [JsonPropertyName("application_id")] public Guid ApplicationId { get; set; }
        [JsonPropertyName("method")] public string Method { get; set; } = "";
        [JsonPropertyName("status")] public string Status { get; set; } = "";
        [JsonPropertyName("proof_path")] public string? ProofPath { get; set; }
        [JsonPropertyName("proof_name")] public string? ProofName { get; set; }
        [JsonPropertyName("amount_reported")] public decimal? AmountReported { get; set; }
        [JsonPropertyName("reported_at")] public DateTimeOffset? ReportedAt { get; set; }
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