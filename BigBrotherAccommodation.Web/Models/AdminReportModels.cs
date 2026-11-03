using System.Text.Json.Serialization;

namespace BigBrotherAccommodation.Web.Models
{
    public class AdminMaintenanceRow
    {
        [JsonPropertyName("request_id")] public Guid Id { get; set; }
        [JsonPropertyName("student_id")] public Guid? StudentId { get; set; }
        [JsonPropertyName("room_id")] public Guid? RoomId { get; set; }
        [JsonPropertyName("reference_code")] public string? ReferenceCode { get; set; }
        [JsonPropertyName("category")] public string? Category { get; set; }
        [JsonPropertyName("priority")] public string? Priority { get; set; }
        [JsonPropertyName("request_type")] public string? RequestType { get; set; }
        [JsonPropertyName("description")] public string? Description { get; set; }
        [JsonPropertyName("photo_path")] public string? PhotoPath { get; set; }
        [JsonPropertyName("photo_url")] public string? PhotoUrl { get; set; }
        [JsonPropertyName("status")] public string? Status { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset? CreatedAt { get; set; }
    }

    public class AdminPaymentRow
    {
        [JsonPropertyName("payment_id")] public Guid Id { get; set; }
        [JsonPropertyName("application_id")] public Guid? ApplicationId { get; set; }
        [JsonPropertyName("amount")] public decimal? Amount { get; set; }
        [JsonPropertyName("payment_method")] public string? PaymentMethod { get; set; }
        [JsonPropertyName("payment_status")] public string? PaymentStatus { get; set; }
        [JsonPropertyName("payment_date")] public DateTime? PaymentDate { get; set; }
        [JsonPropertyName("payment_reference")] public string? PaymentReference { get; set; }
        [JsonPropertyName("proof_of_payment")] public string? ProofOfPayment { get; set; }
        [JsonPropertyName("due_date")] public DateTime? DueDate { get; set; }
        [JsonPropertyName("verified_against_account")] public string? VerifiedAgainstAccount { get; set; }
        [JsonPropertyName("verified_amount")] public decimal? VerifiedAmount { get; set; }
        [JsonPropertyName("verified_date")] public DateTime? VerifiedDate { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset? CreatedAt { get; set; }
    }

    public class AdminAnnouncementRow
    {
        [JsonPropertyName("announcement_id")] public Guid Id { get; set; }
        [JsonPropertyName("user_id")] public Guid? UserId { get; set; }
        [JsonPropertyName("title")] public string? Title { get; set; }
        [JsonPropertyName("message")] public string? Message { get; set; }
        [JsonPropertyName("created_at")] public DateTimeOffset? CreatedAt { get; set; }
    }
}
