using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    public class AccountController : Controller
    {
        public IActionResult Continue()
        {
            return View();
        }
    }
}