using System.Globalization;
using System.Security.Claims;
using BigBrotherAccommodation.Web.Models;
using BigBrotherAccommodation.Web.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BigBrotherAccommodation.Web.Controllers
{
    [Authorize]
    public class ApplicationController : Controller
    {
        private readonly ApplicationService _apps;
        private readonly IConfiguration _config;
        private readonly NotificationService _notifications;

        public ApplicationController(ApplicationService apps, IConfiguration config, NotificationService notifications)
        {
            _apps = apps;
            _config = config;
            _notifications = notifications;
        }

        private bool TryGetStudent(out Guid studentId) =>
            Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out studentId);

        // Step 1: details

        [HttpGet]
        public async Task<IActionResult> Details(Guid? roomId)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            if (await _apps.IsTenantAsync(studentId))
            {
                TempData["Message"] = "You're already a tenant, so you can't apply for another room. Contact management if you plan to move out.";
                return RedirectToAction("Mine");
            }

            if (await _apps.GetActiveAsync(studentId) != null)
            {
                TempData["Message"] = "You already have an application in progress.";
                return RedirectToAction("Mine");
            }

            var draft = await _apps.GetDraftAsync(studentId);

            var claimName = User.FindFirst(ClaimTypes.Name)?.Value;
            if (claimName != null && claimName.Contains('@')) claimName = null;

            var model = new ApplyDetailsViewModel
            {
                RoomId = draft?.RoomId,
                FullName = Pick(draft?.FullName, claimName),
                Email = Pick(draft?.Email, User.FindFirst(ClaimTypes.Email)?.Value),
                Phone = draft?.Phone,
                Institution = draft?.Institution,
                PreferredRoom = draft?.PreferredRoom
            };

            if (roomId.HasValue)
            {
                var room = await _apps.GetRoomAsync(roomId.Value);
                if (room != null && !await _apps.RoomIsOpenAsync(room.Id))
                {
                    TempData["Message"] = "That room is fully occupied. Please choose another available room.";
                    return RedirectToAction("Index", "Rooms");
                }
                if (room != null)
                {
                    model.RoomId = room.Id;
                    model.PreferredRoom = $"{room.Name} - {room.RoomType}";
                }
            }

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Details(ApplyDetailsViewModel model, string? submitAction)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            if (await _apps.GetActiveAsync(studentId) != null)
            {
                return RedirectToAction("Mine");
            }

            var saveOnly = submitAction == "draft";

            if (model.RoomId.HasValue && !await _apps.RoomIsOpenAsync(model.RoomId.Value))
            {
                ModelState.AddModelError("", "That room is fully occupied. Please choose another available room from Browse rooms.");
                return View(model);
            }

            if (!saveOnly && !ModelState.IsValid)
            {
                return View(model);
            }

            var saved = await _apps.SaveDraftAsync(studentId, model);
            if (saved == null)
            {
                ModelState.AddModelError("", "We couldn't save your application. Check the Output window in Visual Studio for the reason.");
                return View(model);
            }

            if (saveOnly)
            {
                TempData["Message"] = "Draft saved. You can come back to finish it any time.";
                return RedirectToAction("Details");
            }

            return RedirectToAction("Documents");
        }

        // Documents

        [HttpGet]
        public async Task<IActionResult> Documents()
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var draft = await _apps.GetDraftAsync(studentId);
            if (draft == null || !DetailsComplete(draft)) return RedirectToAction("Details");

            return View(await BuildDocumentsModelAsync(draft));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [RequestSizeLimit(40_000_000)]
        public async Task<IActionResult> Documents(IFormFile? idFile, IFormFile? registrationFile, IFormFile? incomeFile, string? submitAction)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var draft = await _apps.GetDraftAsync(studentId);
            if (draft == null || !DetailsComplete(draft)) return RedirectToAction("Details");

            var errors = new List<string>();
            var files = new (string Type, IFormFile? File)[]
            {
                ("id", idFile),
                ("registration", registrationFile),
                ("income", incomeFile)
            };

            foreach (var (type, file) in files)
            {
                if (file == null || file.Length == 0) continue;

                var error = await _apps.SaveDocumentAsync(draft, type, file);
                if (error != null) errors.Add(error);
            }

            if (errors.Any())
            {
                var withErrors = await BuildDocumentsModelAsync(draft);
                withErrors.Errors = errors;
                return View(withErrors);
            }

            if (submitAction == "back")
            {
                return RedirectToAction("Details");
            }

            var missing = await _apps.MissingDocumentsAsync(draft.Id);
            if (missing.Any())
            {
                var model = await BuildDocumentsModelAsync(draft);
                model.Errors.Add("Please upload: " + string.Join(", ", missing) + ".");
                return View(model);
            }

            return RedirectToAction("Review");
        }

        // Step 2: review and submit 

        [HttpGet]
        public async Task<IActionResult> Review()
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var draft = await _apps.GetDraftAsync(studentId);
            if (draft == null || !DetailsComplete(draft)) return RedirectToAction("Details");

            if ((await _apps.MissingDocumentsAsync(draft.Id)).Any()) return RedirectToAction("Documents");

            return View(draft);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SubmitApplication()
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var draft = await _apps.GetDraftAsync(studentId);
            if (draft == null) return RedirectToAction("Details");

            var error = await _apps.SubmitAsync(draft);
            if (error != null)
            {
                ModelState.AddModelError("", error);
                return View("Review", draft);
            }

            await _notifications.AddAsync(studentId, "Application received",
                "Your application has been submitted and is waiting for staff review.",
                "/Application/Mine", "Track application");

            return RedirectToAction("Submitted", new { id = draft.Id });
        }

        [HttpGet]
        public async Task<IActionResult> Submitted(Guid id)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var app = await _apps.GetAsync(studentId, id);
            if (app == null) return NotFound();
            if (app.Status == "draft") return RedirectToAction("Review");

            return View(app);
        }

        // My application

        [HttpGet]
        public async Task<IActionResult> Mine()
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var model = new MyApplicationViewModel { App = await _apps.GetLatestAsync(studentId) };
            if (model.App == null)
            {
                model.Draft = await _apps.GetDraftAsync(studentId);
            }

            return View(model);
        }

        // Payment

        [HttpGet]
        public async Task<IActionResult> Payment(Guid id)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var app = await _apps.GetAsync(studentId, id);
            if (app == null) return NotFound();
            if (app.Status != "accepted") return RedirectToAction("Mine");

            var payment = await _apps.GetPaymentAsync(app.Id);
            if (payment?.ProofPath != null) return RedirectToAction("PaymentSubmitted", new { id });

            return View(await BuildPaymentModelAsync(app, payment));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [RequestSizeLimit(15_000_000)]
        public async Task<IActionResult> Payment(Guid id, IFormFile? proof)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var app = await _apps.GetAsync(studentId, id);
            if (app == null) return NotFound();
            if (app.Status != "accepted") return RedirectToAction("Mine");

            var existing = await _apps.GetPaymentAsync(app.Id);
            if (existing?.ProofPath != null) return RedirectToAction("PaymentSubmitted", new { id });

            var model = await BuildPaymentModelAsync(app, existing);
            var (payment, error) = await _apps.SavePaymentAsync(app, model.AmountValue, proof);

            if (error != null)
            {
                ModelState.AddModelError("", error);
                return View(model);
            }

            if (payment?.ProofPath != null)
            {
                return RedirectToAction("PaymentSubmitted", new { id });
            }

            TempData["Message"] = "Payment preference saved. Upload your proof of payment once you have paid.";
            return RedirectToAction("Payment", new { id });
        }

        [HttpGet]
        public async Task<IActionResult> PaymentSubmitted(Guid id)
        {
            if (!TryGetStudent(out var studentId)) return Challenge();

            var app = await _apps.GetAsync(studentId, id);
            if (app == null) return NotFound();

            var payment = await _apps.GetPaymentAsync(app.Id);
            if (payment?.ProofPath == null) return RedirectToAction("Payment", new { id });

            return View(new PaymentSubmittedViewModel
            {
                App = app,
                Payment = payment,
                AmountText = Money(payment.AmountReported),
                ReportedOnText = payment.ReportedAt?.ToLocalTime().ToString("d MMMM yyyy, HH:mm", CultureInfo.InvariantCulture) ?? ""
            });
        }

        // Helpers 

        private static string? Pick(string? first, string? second) =>
            string.IsNullOrWhiteSpace(first) ? second : first;

        private static bool DetailsComplete(ApplicationRecord a) =>
            !string.IsNullOrWhiteSpace(a.FullName) && !string.IsNullOrWhiteSpace(a.Email) &&
            !string.IsNullOrWhiteSpace(a.Phone) && !string.IsNullOrWhiteSpace(a.Institution) &&
            !string.IsNullOrWhiteSpace(a.PreferredRoom);

        private static string Money(decimal? value) =>
            value.HasValue ? "R " + value.Value.ToString("N2", CultureInfo.InvariantCulture) : "R ------.--";

        private async Task<ApplyDocumentsViewModel> BuildDocumentsModelAsync(ApplicationRecord draft)
        {
            var docs = await _apps.GetDocumentsAsync(draft.Id);

            return new ApplyDocumentsViewModel
            {
                Rows = ApplicationService.DocumentSpecs.Select(s => new DocumentRow
                {
                    Label = s.Label,
                    Hint = s.Hint,
                    FieldName = s.Type + "File",
                    UploadedName = docs.FirstOrDefault(d => d.DocType == s.Type)?.OriginalName
                }).ToList()
            };
        }

        private async Task<PaymentInstructionsViewModel> BuildPaymentModelAsync(ApplicationRecord app, PaymentRecord? payment)
        {
            RoomLite? room = app.RoomId.HasValue ? await _apps.GetRoomAsync(app.RoomId.Value) : null;
            var amount = app.AmountDue ?? room?.Price;

            return new PaymentInstructionsViewModel
            {
                App = app,
                Payment = payment,
                AmountValue = amount,
                AmountText = Money(amount),
                DueDateText = app.PaymentDueDate?.ToString("d MMMM yyyy", CultureInfo.InvariantCulture) ?? "To be confirmed",
                AccountHolder = _config["Payment:AccountHolder"] ?? "Mr Ngubane",
                BankName = Fallback(_config["Payment:BankName"]),
                AccountNumber = Fallback(_config["Payment:AccountNumber"]),
                BranchCode = Fallback(_config["Payment:BranchCode"])
            };
        }

        private static string Fallback(string? value) =>
            string.IsNullOrWhiteSpace(value) ? "To be confirmed" : value;
    }
}