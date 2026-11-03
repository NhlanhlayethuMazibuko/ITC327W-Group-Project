using System.Text.Json;
using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    public record DocumentSpec(string Type, string Label, string Hint);

    public class ApplicationService
    {
        public const string DocumentsBucket = "application-documents";
        public const string ProofsBucket = "payment-proofs";
        private const long MaxFileBytes = 10 * 1024 * 1024;
        private const string ApplicationTable = "application";
        private const string StatusTable = "application_status";
        private const string StudentTable = "student";
        private const string DocumentTable = "documents";
        private const string PaymentTable = "payment";

        // Documents students must upload.
        public static readonly DocumentSpec[] DocumentSpecs =
        {
            new("id", "ID or passport", "PDF, JPG or PNG - Max 10 MB"),
            new("registration", "Proof of registration or admission", "Current academic year - PDF, JPG or PNG. Max 10 MB"),
            new("income", "Proof of income / Bursary details", "PDF, JPG or PNG - Max 10 MB")
        };

        private record FileCheck(byte[]? Bytes, string ContentType, string Ext, string? Error);

        private sealed class StatusRow
        {
            [System.Text.Json.Serialization.JsonPropertyName("status_id")] public int Id { get; set; }
            [System.Text.Json.Serialization.JsonPropertyName("status_name")] public string Name { get; set; } = "";
        }

        private sealed class StudentRow
        {
            [System.Text.Json.Serialization.JsonPropertyName("student_id")] public Guid StudentId { get; set; }
            [System.Text.Json.Serialization.JsonPropertyName("user_id")] public Guid? UserId { get; set; }
            [System.Text.Json.Serialization.JsonPropertyName("full_name")] public string? FullName { get; set; }
            [System.Text.Json.Serialization.JsonPropertyName("phone_number")] public string? Phone { get; set; }
            [System.Text.Json.Serialization.JsonPropertyName("institution")] public string? Institution { get; set; }
        }

        private readonly SupabaseServer _db;
        private readonly ProfileService _profiles;
        private readonly IHttpClientFactory _http;
        private readonly ILogger<ApplicationService> _logger;
        private readonly string _url;
        private readonly string _key;

        public ApplicationService(SupabaseServer db, ProfileService profiles, IHttpClientFactory http, IConfiguration config, ILogger<ApplicationService> logger)
        {
            _db = db;
            _profiles = profiles;
            _http = http;
            _logger = logger;
            _url = (config["Supabase:Url"] ?? "").TrimEnd('/');
            _key = (config["Supabase:ServiceKey"] ?? "").Trim().Trim('"');
        }

        // Applications 

        public async Task<ApplicationRecord?> GetDraftAsync(Guid studentId)
        {
            var statusId = await FindStatusIdAsync("Draft");
            var recordId = await _profiles.ResolveStudentIdAsync(studentId);
            return statusId.HasValue
                ? await FirstAsync($"student_id=eq.{recordId}&status_id=eq.{statusId}&order=created_at.desc&limit=1")
                : null;
        }

        public async Task<ApplicationRecord?> GetActiveAsync(Guid studentId)
        {
            var statusIds = await FindStatusIdsAsync("Submitted", "Under Review", "Approved");
            if (statusIds.Count == 0) return null;
            var recordId = await _profiles.ResolveStudentIdAsync(studentId);
            return await FirstAsync($"student_id=eq.{recordId}&status_id=in.({string.Join(",", statusIds)})&order=created_at.desc&limit=1");
        }

        private class RoomOpenRow
        {
            [System.Text.Json.Serialization.JsonPropertyName("availability_status")] public bool Available { get; set; }
        }

        // Full or unavailable rooms can't be applied for
        public async Task<bool> RoomIsOpenAsync(Guid roomId)
        {
            try
            {
                var rows = await _db.SelectAsync<RoomOpenRow>("room", $"room_id=eq.{roomId}&select=availability_status&limit=1");
                return rows.FirstOrDefault()?.Available == true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not check room {RoomId}", roomId);
                return false;
            }
        }

        // A tenant is a student whose application has been approved (until they move out)
        public async Task<bool> IsTenantAsync(Guid studentId)
        {
            var approved = await FindStatusIdAsync("Approved");
            if (!approved.HasValue) return false;
            var recordId = await _profiles.ResolveStudentIdAsync(studentId);
            return await FirstAsync($"student_id=eq.{recordId}&status_id=eq.{approved}&limit=1") != null;
        }

        public async Task<ApplicationRecord?> GetLatestAsync(Guid studentId)
        {
            var statusIds = await FindStatusIdsAsync("Submitted", "Under Review", "Approved", "Rejected");
            if (statusIds.Count == 0) return null;
            var recordId = await _profiles.ResolveStudentIdAsync(studentId);
            return await FirstAsync($"student_id=eq.{recordId}&status_id=in.({string.Join(",", statusIds)})&order=created_at.desc&limit=1");
        }

        public async Task<ApplicationRecord?> GetAsync(Guid studentId, Guid id)
        {
            var recordId = await _profiles.ResolveStudentIdAsync(studentId);
            return await FirstAsync($"application_id=eq.{id}&student_id=eq.{recordId}&limit=1");
        }

        private async Task<ApplicationRecord?> FirstAsync(string query)
        {
            try
            {
                var rows = await _db.SelectAsync<ApplicationRecord>(ApplicationTable, query);
                var record = rows.FirstOrDefault();
                return record == null ? null : await HydrateAsync(record);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load application from Supabase");
                return null;
            }
        }

        public async Task<RoomLite?> GetRoomAsync(Guid roomId)
        {
            try
            {
                var rows = await _db.SelectAsync<RoomLite>("room",
                    $"room_id=eq.{roomId}&select=room_id,room_name,room_type,price&limit=1");
                return rows.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load room {RoomId}", roomId);
                return null;
            }
        }

        public async Task<ApplicationRecord?> SaveDraftAsync(Guid studentId, ApplyDetailsViewModel m)
        {
            try
            {
                var draftStatusId = await FindStatusIdAsync("Draft");
                if (!draftStatusId.HasValue)
                {
                    _logger.LogError("Supabase application_status has no Draft row; add a status named Draft to Supabase.");
                    return null;
                }

                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                await _db.UpsertAsync(StudentTable, "student_id", new
                {
                    student_id = recordId,
                    user_id = studentId,
                    full_name = (m.FullName ?? "").Trim(),
                    phone_number = (m.Phone ?? "").Trim(),
                    institution = (m.Institution ?? "").Trim()
                });

                var draft = await GetDraftAsync(studentId);
                if (draft == null)
                {
                    var created = await _db.InsertAsync<ApplicationRecord>(ApplicationTable, new
                    {
                        student_id = recordId,
                        room_id = m.RoomId,
                        status_id = draftStatusId.Value,
                        application_number = $"APP-{Guid.NewGuid():N}".ToUpperInvariant()
                    });
                    return created == null ? null : await HydrateAsync(created);
                }

                await _db.UpdateAsync(ApplicationTable,
                    $"application_id=eq.{draft.Id}&student_id=eq.{recordId}&status_id=eq.{draftStatusId.Value}",
                    new { room_id = m.RoomId });

                return await GetAsync(studentId, draft.Id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not save application draft");
                return null;
            }
        }

        // Return an error message, or null when the application was submitted.
        public async Task<string?> SubmitAsync(ApplicationRecord app)
        {
            if (string.IsNullOrWhiteSpace(app.FullName) || string.IsNullOrWhiteSpace(app.Email) ||
                string.IsNullOrWhiteSpace(app.Phone) || string.IsNullOrWhiteSpace(app.Institution) ||
                !app.RoomId.HasValue)
            {
                return "Some of your details are missing. Go back and complete step 1.";
            }

            if (!await RoomIsOpenAsync(app.RoomId.Value))
            {
                return "Sorry, that room has just been filled. Go back to step 1 and choose another available room.";
            }

            var missing = await MissingDocumentsAsync(app.Id);
            if (missing.Any()) return "Please upload: " + string.Join(", ", missing) + ".";

            try
            {
                var submittedStatusId = await FindStatusIdAsync("Submitted");
                var draftStatusId = await FindStatusIdAsync("Draft");
                if (!submittedStatusId.HasValue || !draftStatusId.HasValue)
                {
                    return "The Draft or Submitted status is missing from Supabase application_status.";
                }

                await _db.UpdateAsync(ApplicationTable,
                    $"application_id=eq.{app.Id}&student_id=eq.{app.StudentId}&status_id=eq.{draftStatusId.Value}",
                    new { status_id = submittedStatusId.Value, application_date = DateTime.UtcNow.Date });
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not submit application {Id}", app.Id);
                return "We couldn't submit your application. Please try again.";
            }
        }

        // Documents 

        public async Task<List<ApplicationDocument>> GetDocumentsAsync(Guid applicationId)
        {
            try
            {
                var documents = await _db.SelectAsync<ApplicationDocument>(DocumentTable,
                    $"application_id=eq.{applicationId}&order=upload_date.asc");
                foreach (var document in documents)
                {
                    var name = Path.GetFileName(document.FilePath);
                    var parts = name.Split('-', 3);
                    document.OriginalName = parts.Length == 3 ? parts[2] : name;
                }
                return documents;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load documents from Supabase");
                return new List<ApplicationDocument>();
            }
        }

        public async Task<List<string>> MissingDocumentsAsync(Guid applicationId)
        {
            var docs = await GetDocumentsAsync(applicationId);
            return DocumentSpecs.Where(s => docs.All(d => d.DocType != s.Type)).Select(s => s.Label).ToList();
        }

        // Return an error message, or null when the file was saved.
        public async Task<string?> SaveDocumentAsync(ApplicationRecord app, string type, IFormFile file)
        {
            var check = await ReadFileAsync(file);
            if (check.Error != null) return check.Error;

            try
            {
                var existing = (await GetDocumentsAsync(app.Id)).FirstOrDefault(d => d.DocType == type);
                var path = $"{app.StudentId}/{app.Id}/{type}-{Guid.NewGuid():N}-{SafeName(file.FileName)}";
                await _db.UploadAsync(DocumentsBucket, path, check.Bytes!, check.ContentType);

                var saved = await _db.InsertAsync<ApplicationDocument>(DocumentTable, new
                {
                    application_id = app.Id,
                    document_type = type,
                    file_path = path,
                    upload_date = DateTimeOffset.UtcNow
                });

                if (saved == null)
                {
                    await _db.DeleteObjectAsync(DocumentsBucket, path);
                    return $"We couldn't upload {SafeName(file.FileName)}. Please try again.";
                }

                if (existing != null)
                {
                    await _db.DeleteAsync(DocumentTable, $"document_id=eq.{existing.Id}");
                    await _db.DeleteObjectAsync(DocumentsBucket, existing.FilePath);
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Document upload failed");
                return $"We couldn't upload {SafeName(file.FileName)}. Please try again.";
            }
        }

        // Payment

        public async Task<PaymentRecord?> GetPaymentAsync(Guid applicationId)
        {
            try
            {
                var rows = await _db.SelectAsync<PaymentRecord>(PaymentTable,
                    $"application_id=eq.{applicationId}&order=created_at.desc&limit=1");
                return rows.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load payment from Supabase");
                return null;
            }
        }

        public async Task<(PaymentRecord? Payment, string? Error)> SavePaymentAsync(ApplicationRecord app, decimal? amountDue, IFormFile? proof)
        {
            try
            {
                var hasProof = proof != null && proof.Length > 0;
                string? path = null;

                if (hasProof)
                {
                    var check = await ReadFileAsync(proof!);
                    if (check.Error != null) return (null, check.Error);

                    path = $"{app.StudentId}/{app.Id}/proof-{Guid.NewGuid():N}-{SafeName(proof!.FileName)}";
                    await _db.UploadAsync(ProofsBucket, path, check.Bytes!, check.ContentType);
                }

                var existing = await GetPaymentAsync(app.Id);
                if (existing == null)
                {
                    var created = await _db.InsertAsync<PaymentRecord>(PaymentTable, new
                    {
                        application_id = app.Id,
                        amount = amountDue,
                        payment_method = "Bank transfer/EFT",
                        payment_status = hasProof ? "awaiting_verification" : "preference_saved",
                        payment_date = hasProof ? DateTime.UtcNow.Date : (DateTime?)null,
                        proof_of_payment = path,
                        due_date = app.PaymentDueDate
                    });
                    if (created == null && path != null) await _db.DeleteObjectAsync(ProofsBucket, path);
                    return (created, created == null ? "We couldn't save your payment details. Please try again." : null);
                }

                if (!hasProof) return (existing, null);

                await _db.UpdateAsync(PaymentTable, $"payment_id=eq.{existing.Id}", new
                {
                    amount = amountDue,
                    payment_method = "Bank transfer/EFT",
                    payment_status = "awaiting_verification",
                    payment_date = DateTime.UtcNow.Date,
                    proof_of_payment = path,
                    due_date = app.PaymentDueDate
                });

                if (existing.ProofPath != null) await _db.DeleteObjectAsync(ProofsBucket, existing.ProofPath);
                return (await GetPaymentAsync(app.Id), null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not save payment");
                return (null, "We couldn't save your payment details. Please try again.");
            }
        }

        private async Task<ApplicationRecord> HydrateAsync(ApplicationRecord app)
        {
            var students = await _db.SelectAsync<StudentRow>(StudentTable,
                $"student_id=eq.{app.StudentId}&select=student_id,user_id,full_name,phone_number,institution&limit=1");
            var student = students.FirstOrDefault();
            if (student != null)
            {
                app.FullName = student.FullName ?? "";
                app.Phone = student.Phone ?? "";
                app.Institution = student.Institution ?? "";
                app.Email = await GetAuthEmailAsync(student.UserId ?? app.StudentId);
            }

            var statuses = await _db.SelectAsync<StatusRow>(StatusTable, "select=status_id,status_name");
            app.Status = statuses.FirstOrDefault(s => s.Id == app.StatusId)?.Name.ToLowerInvariant() switch
            {
                "under review" => "reviewing",
                "approved" => "accepted",
                "rejected" => "declined",
                var value when !string.IsNullOrWhiteSpace(value) => value,
                _ => ""
            };

            if (app.RoomId.HasValue)
            {
                var room = await GetRoomAsync(app.RoomId.Value);
                if (room != null)
                {
                    app.PreferredRoom = $"{room.Name} - {room.RoomType}";
                    app.AmountDue = room.Price;
                }
            }

            var payment = await GetPaymentAsync(app.Id);
            app.PaymentDueDate = payment?.DueDate;
            return app;
        }

        private async Task<int?> FindStatusIdAsync(string statusName)
        {
            var statuses = await _db.SelectAsync<StatusRow>(StatusTable, "select=status_id,status_name");
            return statuses.FirstOrDefault(s => string.Equals(s.Name, statusName, StringComparison.OrdinalIgnoreCase))?.Id;
        }

        private async Task<List<int>> FindStatusIdsAsync(params string[] names)
        {
            var statuses = await _db.SelectAsync<StatusRow>(StatusTable, "select=status_id,status_name");
            return statuses.Where(s => names.Contains(s.Name, StringComparer.OrdinalIgnoreCase))
                .Select(s => s.Id).Distinct().ToList();
        }

        private async Task<string> GetAuthEmailAsync(Guid userId)
        {
            if (string.IsNullOrEmpty(_url) || string.IsNullOrEmpty(_key)) return "";

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Get, $"{_url}/auth/v1/admin/users/{userId}");
                request.Headers.Add("apikey", _key);
                request.Headers.TryAddWithoutValidation("Authorization", "Bearer " + _key);
                using var response = await _http.CreateClient().SendAsync(request);
                if (!response.IsSuccessStatusCode) return "";

                using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
                return document.RootElement.TryGetProperty("email", out var email) ? email.GetString() ?? "" : "";
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not load student email from Supabase Auth");
                return "";
            }
        }

        // File checks

        private static async Task<FileCheck> ReadFileAsync(IFormFile file)
        {
            var name = SafeName(file.FileName);
            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();

            var contentType = ext switch
            {
                ".pdf" => "application/pdf",
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                _ => ""
            };

            if (contentType == "") return new FileCheck(null, "", "", $"{name}: only PDF, JPG or PNG files are accepted.");
            if (file.Length == 0) return new FileCheck(null, "", "", $"{name} is empty.");
            if (file.Length > MaxFileBytes) return new FileCheck(null, "", "", $"{name} is larger than 10 MB.");

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            var bytes = ms.ToArray();

            var valid = contentType switch
            {
                "application/pdf" => StartsWith(bytes, 0x25, 0x50, 0x44, 0x46),
                "image/jpeg" => StartsWith(bytes, 0xFF, 0xD8, 0xFF),
                _ => StartsWith(bytes, 0x89, 0x50, 0x4E, 0x47)
            };

            if (!valid) return new FileCheck(null, "", "", $"{name} doesn't look like a valid file. Please choose another.");

            return new FileCheck(bytes, contentType, ext == ".jpeg" ? ".jpg" : ext, null);
        }

        private static bool StartsWith(byte[] bytes, params byte[] signature) =>
            bytes.Length >= signature.Length && bytes.Take(signature.Length).SequenceEqual(signature);

        private static string SafeName(string fileName)
        {
            var name = Path.GetFileName(fileName);
            name = new string(name.Where(c => !char.IsControl(c) && c != '/' && c != '\\').ToArray());
            return name.Length > 120 ? name[..120] : name;
        }
    }
}