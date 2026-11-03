using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace BigBrotherAccommodation.Web.Models
{
    public class ProfileRecord
    {
        [JsonPropertyName("student_id")] public Guid StudentId { get; set; }
        [JsonPropertyName("user_id")] public Guid? UserId { get; set; }
        [JsonPropertyName("full_name")] public string FullName { get; set; } = "";
        [JsonPropertyName("phone_number")] public string Phone { get; set; } = "";
        [JsonPropertyName("institution")] public string Institution { get; set; } = "";
        [JsonPropertyName("student_number")] public string StudentNumber { get; set; } = "";

        [JsonIgnore]
        public string FirstName => FullName.Split(' ', 2, StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? "";

        [JsonIgnore]
        public string LastName
        {
            get
            {
                var parts = FullName.Split(' ', 2, StringSplitOptions.RemoveEmptyEntries);
                return parts.Length > 1 ? parts[1] : "";
            }
        }
    }

    public class ProfileViewModel
    {
        [Required(ErrorMessage = "Enter your first name")]
        [StringLength(60)]
        public string? FirstName { get; set; }

        [Required(ErrorMessage = "Enter your last name")]
        [StringLength(60)]
        public string? LastName { get; set; }

        [RegularExpression(@"^\+?[0-9\s]{9,15}$", ErrorMessage = "Enter a valid phone number")]
        public string? Phone { get; set; }

        [StringLength(100)]
        public string? Institution { get; set; }

        [StringLength(40)]
        public string? StudentNumber { get; set; }

        public string Email { get; set; } = "";
    }
}