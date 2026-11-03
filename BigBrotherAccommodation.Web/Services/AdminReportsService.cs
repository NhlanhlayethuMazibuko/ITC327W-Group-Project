using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    public class AdminReportsService
    {
        private readonly SupabaseServer _db;
        private readonly NotificationService _notifications;
        private readonly ILogger<AdminReportsService> _logger;

        public AdminReportsService(SupabaseServer db, NotificationService notifications, ILogger<AdminReportsService> logger)
        {
            _db = db;
            _notifications = notifications;
            _logger = logger;
        }

        public async Task<AdminMaintenanceReportsViewModel> GetMaintenanceAsync()
        {
            var model = new AdminMaintenanceReportsViewModel();

            try
            {
                var records = await _db.SelectAsync<AdminMaintenanceRow>(
                    "maintenance_requests", "order=created_at.desc&limit=500");
                var students = await GetStudentsAsync(records.Where(r => r.StudentId.HasValue).Select(r => r.StudentId!.Value));
                var rooms = await GetRoomsAsync(records.Select(r => r.RoomId));

                model.Items = records.Select(record =>
                {
                    var studentId = record.StudentId ?? Guid.Empty;
                    students.TryGetValue(studentId, out var student);
                    var room = record.RoomId.HasValue && rooms.TryGetValue(record.RoomId.Value, out var roomRecord)
                        ? roomRecord.Name
                        : "";

                    return new AdminMaintenanceReportItem
                    {
                        Record = record,
                        StudentName = student?.FullName ?? studentId.ToString(),
                        StudentNumber = student?.StudentNumber ?? "",
                        Room = room
                    };
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load maintenance reports from Supabase");
                model.LoadFailed = true;
            }

            return model;
        }

        public static readonly string[] MaintenanceStatuses =
            { "submitted", "acknowledged", "in_progress", "waiting", "resolved", "closed" };

        public async Task<AdminMaintenanceDetailViewModel?> GetMaintenanceDetailAsync(Guid id)
        {
            try
            {
                var record = (await _db.SelectAsync<AdminMaintenanceRow>(
                    "maintenance_requests", $"request_id=eq.{id}&limit=1")).FirstOrDefault();
                if (record == null) return null;

                var model = new AdminMaintenanceDetailViewModel
                {
                    Record = record,
                    Form = new AdminMaintenanceUpdateForm { Status = record.Status }
                };

                if (record.StudentId.HasValue)
                {
                    var student = (await _db.SelectAsync<AdminStudentRow>("student",
                        $"student_id=eq.{record.StudentId}&select=student_id,user_id,full_name,student_number,phone_number&limit=1")).FirstOrDefault();
                    model.StudentName = student?.FullName ?? "";
                    model.StudentNumber = student?.StudentNumber ?? "";
                    model.Phone = student?.PhoneNumber ?? "";
                }

                var rooms = await GetRoomsAsync(new[] { record.RoomId });
                if (record.RoomId.HasValue && rooms.TryGetValue(record.RoomId.Value, out var room))
                {
                    model.Room = $"{room.Name} - {room.RoomType}";
                }

                model.PhotoUrl = !string.IsNullOrWhiteSpace(record.PhotoUrl) ? record.PhotoUrl
                    : !string.IsNullOrWhiteSpace(record.PhotoPath) ? await _db.SignedUrlAsync(MaintenanceService.PhotoBucket, record.PhotoPath)
                    : null;

                model.Updates = await _db.SelectAsync<MaintenanceUpdate>("maintenance_update",
                    $"request_id=eq.{id}&order=created_at.asc");
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load maintenance request {Id}", id);
                return null;
            }
        }

        // Changes the status, records it in the request's history and tells the student
        public async Task<string?> UpdateMaintenanceAsync(Guid id, AdminMaintenanceUpdateForm form, Guid? staffUserId)
        {
            if (string.IsNullOrEmpty(form.Status) || !MaintenanceStatuses.Contains(form.Status))
                return "Choose a status.";
            var message = (form.Message ?? "").Trim();
            if (message.Length > 1000) return "Keep the update under 1000 characters.";

            try
            {
                var record = (await _db.SelectAsync<AdminMaintenanceRow>(
                    "maintenance_requests", $"request_id=eq.{id}&limit=1")).FirstOrDefault();
                if (record == null) return "The request could not be found.";

                await _db.UpdateAsync("maintenance_requests", $"request_id=eq.{id}", new { status = form.Status });

                var label = MaintenanceRecord.LabelFor(form.Status);
                if (message == "") message = $"Status changed to {label}.";
                await _db.InsertAsync<MaintenanceUpdate>("maintenance_update", new
                {
                    request_id = id,
                    user_id = staffUserId,
                    status = form.Status,
                    message
                });

                if (record.StudentId.HasValue)
                {
                    await _notifications.AddForStudentRecordAsync(record.StudentId.Value,
                        $"Maintenance update: {label}",
                        $"{record.ReferenceCode}: {message}", "maintenance");
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not update maintenance request {Id}", id);
                return "We couldn't save the update. Check the Output window in Visual Studio for the reason.";
            }
        }

        public async Task<string?> SavePaymentVerificationAsync(Guid paymentId, AdminPaymentVerificationForm form)
        {
            var allowed = new[] { "Yes", "No", "Need more information" };
            if (!allowed.Contains(form.VerifiedAgainstAccount))
            {
                return "Choose whether the payment matches the account.";
            }

            if (form.VerifiedAgainstAccount == "Yes" && (!form.VerifiedAmount.HasValue || !form.VerifiedDate.HasValue))
            {
                return "Enter the verified amount and date.";
            }

            var status = form.VerifiedAgainstAccount switch
            {
                "Yes" => "verified",
                "No" => "not_verified",
                _ => "needs_more_information"
            };

            try
            {
                await _db.UpdateAsync("payment", $"payment_id=eq.{paymentId}", new
                {
                    verified_against_account = form.VerifiedAgainstAccount,
                    verified_amount = form.VerifiedAmount,
                    verified_date = form.VerifiedDate,
                    payment_status = status
                });
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not save payment verification for {PaymentId}", paymentId);
                return "We couldn't save the payment verification. Check the Output window for details.";
            }
        }

        public async Task<AdminPaymentsViewModel> GetPaymentsAsync()
        {
            var model = new AdminPaymentsViewModel();

            try
            {
                var payments = await _db.SelectAsync<AdminPaymentRow>(
                    "payment", "order=created_at.desc&limit=500");
                var applicationIds = payments.Where(p => p.ApplicationId.HasValue)
                    .Select(p => p.ApplicationId!.Value).Distinct().ToList();
                var applications = applicationIds.Count == 0
                    ? new List<AdminApplicationRow>()
                    : await _db.SelectAsync<AdminApplicationRow>(
                        "application", $"application_id=in.({string.Join(",", applicationIds)})&select=application_id,student_id,room_id,status_id,application_number,application_date,created_at,staff_note");
                var students = await GetStudentsAsync(applications.Where(a => a.StudentId != Guid.Empty).Select(a => a.StudentId));
                var rooms = await GetRoomsAsync(applications.Select(a => a.RoomId));
                var applicationMap = applications.ToDictionary(a => a.Id);

                model.Items = payments.Select(payment =>
                {
                    AdminApplicationRow? application = null;
                    if (payment.ApplicationId.HasValue)
                    {
                        applicationMap.TryGetValue(payment.ApplicationId.Value, out application);
                    }

                    AdminStudentRow? student = null;
                    if (application != null)
                    {
                        students.TryGetValue(application.StudentId, out student);
                    }

                    var room = application?.RoomId is Guid roomId && rooms.TryGetValue(roomId, out var roomRecord)
                        ? roomRecord.Name
                        : "";

                    return new AdminPaymentItem
                    {
                        Payment = payment,
                        StudentName = student?.FullName ?? application?.StudentId.ToString() ?? "",
                        StudentNumber = student?.StudentNumber ?? "",
                        Room = room
                    };
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load payment records from Supabase");
                model.LoadFailed = true;
            }

            return model;
        }

        public async Task<AdminAnnouncementsViewModel> GetAnnouncementsAsync()
        {
            var model = new AdminAnnouncementsViewModel();

            try
            {
                model.Items = await _db.SelectAsync<AdminAnnouncementRow>(
                    "announcement", "order=created_at.desc&limit=500");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load announcements from Supabase");
                model.LoadFailed = true;
            }

            return model;
        }

        public async Task<AdminAnnouncementDetailsViewModel?> GetAnnouncementAsync(Guid id)
        {
            try
            {
                var rows = await _db.SelectAsync<AdminAnnouncementRow>(
                    "announcement", $"announcement_id=eq.{id}&limit=1");
                var announcement = rows.FirstOrDefault();
                if (announcement == null) return null;

                return new AdminAnnouncementDetailsViewModel
                {
                    Announcement = announcement,
                    Publisher = announcement.UserId?.ToString() ?? ""
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load announcement {Id} from Supabase", id);
                return null;
            }
        }

        public async Task<bool> CreateAnnouncementAsync(Guid? userId, AdminAnnouncementForm form)
        {
            try
            {
                var record = await _db.InsertAsync<AdminAnnouncementRow>("announcement", new
                {
                    user_id = userId,
                    title = form.Title!.Trim(),
                    message = form.Message!.Trim()
                });
                if (record == null) return false;

                var students = await _db.SelectAsync<AdminStudentRow>(
                    "student", "select=student_id");
                foreach (var student in students)
                {
                    await _notifications.AddForStudentRecordAsync(
                        student.StudentId,
                        form.Title.Trim(),
                        form.Message.Trim(),
                        "announcement");
                }

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not create announcement in Supabase");
                return false;
            }
        }

        private async Task<Dictionary<Guid, AdminStudentRow>> GetStudentsAsync(IEnumerable<Guid> studentIds)
        {
            var ids = studentIds.Distinct().ToList();
            if (ids.Count == 0) return new Dictionary<Guid, AdminStudentRow>();

            var students = await _db.SelectAsync<AdminStudentRow>(
                "student", $"student_id=in.({string.Join(",", ids)})&select=student_id,user_id,full_name,student_number");
            return students.ToDictionary(s => s.StudentId);
        }

        private async Task<Dictionary<Guid, RoomLite>> GetRoomsAsync(IEnumerable<Guid?> roomIds)
        {
            var ids = roomIds.Where(id => id.HasValue).Select(id => id!.Value).Distinct().ToList();
            if (ids.Count == 0) return new Dictionary<Guid, RoomLite>();

            var rooms = await _db.SelectAsync<RoomLite>(
                "room", $"room_id=in.({string.Join(",", ids)})&select=room_id,room_name,room_type,price");
            return rooms.ToDictionary(room => room.Id);
        }
    }
}
