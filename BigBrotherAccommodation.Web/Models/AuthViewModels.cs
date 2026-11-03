using System.ComponentModel.DataAnnotations;

namespace BigBrotherAccommodation.Web.Models
{
    public class SignInViewModel
    {
        [Required(ErrorMessage = "Enter your email")]
        [EmailAddress(ErrorMessage = "Enter a valid email address")]
        public string Email { get; set; } = "";

        [Required(ErrorMessage = "Enter your password")]
        public string Password { get; set; } = "";

        public bool RememberMe { get; set; }
        public string? ReturnUrl { get; set; }
    }

    public class SignUpViewModel
    {
        [Required(ErrorMessage = "Enter your first name")]
        public string FirstName { get; set; } = "";

        [Required(ErrorMessage = "Enter your last name")]
        public string LastName { get; set; } = "";

        [Required(ErrorMessage = "Enter your email")]
        [EmailAddress(ErrorMessage = "Enter a valid email address")]
        public string Email { get; set; } = "";

        [Required(ErrorMessage = "Create a password")]
        [MinLength(8, ErrorMessage = "Password must be at least 8 characters")]
        public string Password { get; set; } = "";

        [Required(ErrorMessage = "Confirm your password")]
        [Compare("Password", ErrorMessage = "Passwords do not match")]
        public string ConfirmPassword { get; set; } = "";
    }

    public class ForgotPasswordViewModel
    {
        [Required(ErrorMessage = "Enter your email")]
        [EmailAddress(ErrorMessage = "Enter a valid email address")]
        public string Email { get; set; } = "";

        public bool Sent { get; set; }
    }

    public class VerifyEmailViewModel
    {
        [Required(ErrorMessage = "Enter your email")]
        [EmailAddress(ErrorMessage = "Enter a valid email address")]
        public string Email { get; set; } = "";

        [Required(ErrorMessage = "Enter the code from your email")]
        public string Code { get; set; } = "";
    }

    public class ResetPasswordViewModel
    {
        // Filled in by the page script when an older emailed link is used
        public string AccessToken { get; set; } = "";

        // The emailed code route (used by the current email template)
        public string? Email { get; set; }
        public string? Code { get; set; }

        [Required(ErrorMessage = "Create a new password")]
        [MinLength(8, ErrorMessage = "Password must be at least 8 characters")]
        public string Password { get; set; } = "";

        [Required(ErrorMessage = "Confirm your new password")]
        [Compare("Password", ErrorMessage = "Passwords do not match")]
        public string ConfirmPassword { get; set; } = "";
    }
}