using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;
using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    // Staff-side reading and updating of applications, viewing requests (booking) and student records.
    public class AdminCaseService
    {
        private const string ApplicationTable = "application";
        private const string StudentTable = "student";
        private const string BookingTable = "booking";
        private const string RoomTable = "room";

        // application_status ids
        private const int Submitted = 1;
        private const int UnderReview = 2;
        private const int Approved = 3;
        private const int Rejected = 4;

        private static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        private readonly SupabaseServer _db;
        private readonly NotificationService _notifications;
        private readonly IHttpClientFactory _http;
        private readonly ILogger<AdminCaseService> _logger;
        private readonly string _url;
        private readonly string _key;

        public AdminCaseService(SupabaseServer db, NotificationService notifications, IHttpClientFactory http, IConfiguration config,
            ILogger<AdminCaseService> logger)
        {
            _db = db;
            _notifications = notifications;
            _http = http;
            _logger = logger;
            _url = (config["Supabase:Url"] ?? "").TrimEnd('/');
            _key = config["Supabase:ServiceKey"] ?? "";
        }

        // ---------- Labels ----------

        public static (string Key, string Label) Stage(int statusId) => statusId switch
        {
            UnderReview => ("reviewing", "Reviewing"),
            Approved or Rejected => ("decision", "Decision"),
            _ => ("submitted", "Submitted")
        };

        public static string OutcomeText(int statusId) => statusId switch
        {
            Approved => "Approved",
            Rejected => "Rejected",
            _ => "Pending"
        };

        // Flutter and the web both write booking_status as text. Anything staff have not answered counts as requested.
        public static string BookingKey(string? status) => (status ?? "").Trim().ToLowerInvariant() switch
        {
            "confirmed" => "confirmed",
            "rescheduled" => "rescheduled",
            "declined" => "declined",
            "cancelled" or "canceled" => "cancelled",
            "completed" => "completed",
            _ => "requested"
        };

        public static string BookingLabel(string? status) => BookingKey(status) switch
        {
            "confirmed" => "Confirmed",
            "rescheduled" => "Alternative suggested",
            "declined" => "Declined",
            "cancelled" => "Cancelled",
            "completed" => "Completed",
            _ => "Requested"
        };

        private static string DayOf(DateTime? value) =>
            value == null ? "-" : value.Value.ToString("d MMMM", Inv);

        private static string DayOf(DateTimeOffset? value) =>
            value == null ? "-" : value.Value.ToLocalTime().ToString("d MMMM", Inv);

        private static string DayYearOf(DateTimeOffset? value) =>
            value == null ? "-" : value.Value.ToLocalTime().ToString("d MMMM yyyy", Inv);

        private static DateTime? SubmittedOn(AdminApplicationRow a) =>
            a.ApplicationDate ?? a.CreatedAt?.ToLocalTime().Date;

        private static long Unix(DateTime? value) =>
            value == null ? 0 : new DateTimeOffset(DateTime.SpecifyKind(value.Value.Date, DateTimeKind.Utc)).ToUnixTimeSeconds();

        private static string Ref(string? code, Guid id, string prefix) =>
            string.IsNullOrWhiteSpace(code) ? $"{prefix}-{id.ToString()[..8].ToUpperInvariant()}" : code;

        private static string Clean(string? value) => string.IsNullOrWhiteSpace(value) ? "-" : value;

        private static string NameOf(Dictionary<Guid, AdminStudentRow> students, Guid id) =>
            students.TryGetValue(id, out var s) && !string.IsNullOrWhiteSpace(s.FullName) ? s.FullName! : "Student";

        // ---------- Dashboard counts ----------

        public async Task<(int Applications, int Viewings, int NewApplications)> CountOpenAsync()
        {
            try
            {
                var apps = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"status_id=in.({Submitted},{UnderReview})&select=application_id");
                var newApps = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"status_id=eq.{Submitted}&select=application_id");
                var bookings = await _db.SelectAsync<AdminBookingRow>(BookingTable, "select=booking_id,booking_status");
                return (apps.Count, bookings.Count(b => BookingKey(b.BookingStatus) == "requested"), newApps.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not count open applications and viewings");
                return (0, 0, 0);
            }
        }

        // ---------- Lookups ----------

        private async Task<Dictionary<Guid, RoomLite>> RoomsAsync(IEnumerable<Guid?> ids)
        {
            var list = ids.Where(i => i.HasValue).Select(i => i!.Value).Distinct().ToList();
            if (list.Count == 0) return new Dictionary<Guid, RoomLite>();

            var rows = await _db.SelectAsync<RoomLite>(RoomTable,
                $"room_id=in.({string.Join(",", list)})&select=room_id,room_name,room_type,price");
            return rows.ToDictionary(r => r.Id);
        }

        private static string RoomText(Dictionary<Guid, RoomLite> rooms, Guid? roomId)
        {
            if (roomId.HasValue && rooms.TryGetValue(roomId.Value, out var room) && !string.IsNullOrWhiteSpace(room.Name))
            {
                return room.Name;
            }
            return "-";
        }

        private async Task<Dictionary<Guid, AdminStudentRow>> StudentsAsync(IEnumerable<Guid> ids)
        {
            var list = ids.Distinct().ToList();
            if (list.Count == 0) return new Dictionary<Guid, AdminStudentRow>();

            var rows = await _db.SelectAsync<AdminStudentRow>(StudentTable,
                $"student_id=in.({string.Join(",", list)})&select=student_id,user_id,full_name,student_number,phone_number,institution");
            return rows.ToDictionary(r => r.StudentId);
        }

        // Email lives in Supabase Auth, not in the student table.
        private async Task<string> EmailAsync(Guid? userId)
        {
            if (userId == null || string.IsNullOrEmpty(_url) || string.IsNullOrEmpty(_key)) return "-";

            try
            {
                using var req = new HttpRequestMessage(HttpMethod.Get, $"{_url}/auth/v1/admin/users/{userId}");
                req.Headers.Add("apikey", _key);
                if (_key.StartsWith("eyJ"))
                {
                    req.Headers.TryAddWithoutValidation("Authorization", "Bearer " + _key);
                }

                using var res = await _http.CreateClient().SendAsync(req);
                if (!res.IsSuccessStatusCode) return "-";

                using var doc = JsonDocument.Parse(await res.Content.ReadAsStringAsync());
                return doc.RootElement.TryGetProperty("email", out var e) && e.GetString() is { Length: > 0 } value
                    ? value
                    : "-";
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not load email for user {UserId}", userId);
                return "-";
            }
        }

        // ---------- Applications ----------

        public async Task<AdminApplicationsViewModel> GetApplicationsAsync()
        {
            var vm = new AdminApplicationsViewModel();

            try
            {
                var apps = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"status_id=in.({Submitted},{UnderReview},{Approved},{Rejected})&order=created_at.desc&limit=500");
                var rooms = await RoomsAsync(apps.Select(a => a.RoomId));
                var students = await StudentsAsync(apps.Select(a => a.StudentId));

                vm.Items = apps.Select(a =>
                {
                    var (key, label) = Stage(a.StatusId);
                    var name = NameOf(students, a.StudentId);
                    var reference = Ref(a.ApplicationNumber, a.Id, "APP");

                    return new AdminApplicationListItem
                    {
                        Id = a.Id,
                        Reference = reference,
                        Student = name,
                        Room = RoomText(rooms, a.RoomId),
                        SubmittedText = DayOf(SubmittedOn(a)),
                        SortKey = Unix(SubmittedOn(a)),
                        StageKey = key,
                        StageLabel = label,
                        SearchText = $"{name} {reference}".ToLowerInvariant()
                    };
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load applications");
                vm.LoadFailed = true;
            }

            return vm;
        }

        public async Task<AdminApplicationReviewViewModel?> GetApplicationReviewAsync(Guid id)
        {
            try
            {
                var rows = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable, $"application_id=eq.{id}&limit=1");
                var a = rows.FirstOrDefault();
                if (a == null) return null;

                var rooms = await RoomsAsync(new Guid?[] { a.RoomId });
                var students = await StudentsAsync(new[] { a.StudentId });
                students.TryGetValue(a.StudentId, out var s);
                var (key, label) = Stage(a.StatusId);

                return new AdminApplicationReviewViewModel
                {
                    Id = a.Id,
                    Reference = Ref(a.ApplicationNumber, a.Id, "APP"),
                    SubmittedText = DayOf(SubmittedOn(a)),
                    StageKey = key,
                    StageLabel = label,
                    OutcomeLabel = a.StatusId is Approved or Rejected ? OutcomeText(a.StatusId) : "",
                    Name = Clean(s?.FullName),
                    Email = await EmailAsync(s?.UserId),
                    Phone = Clean(s?.PhoneNumber),
                    Institution = Clean(s?.Institution),
                    StudentNumber = Clean(s?.StudentNumber),
                    Room = RoomText(rooms, a.RoomId),
                    Form = new ApplicationStageForm
                    {
                        Stage = key,
                        Outcome = a.StatusId == Approved ? "approved" : a.StatusId == Rejected ? "rejected" : "",
                        Note = a.StaffNote
                    }
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load application {Id}", id);
                return null;
            }
        }

        // Returns an error message, or null when saved.
        public async Task<string?> UpdateApplicationAsync(Guid id, ApplicationStageForm form)
        {
            // An outcome is a decision even if the stage box was left as it was
            if (form.Outcome is "approved" or "rejected") form.Stage = "decision";

            var statusId = form.Stage switch
            {
                "submitted" => Submitted,
                "reviewing" => UnderReview,
                "decision" => form.Outcome == "approved" ? Approved : form.Outcome == "rejected" ? Rejected : 0,
                _ => 0
            };

            if (statusId == 0)
            {
                return form.Stage == "decision"
                    ? "Choose an outcome: Approved or Rejected."
                    : "Choose a stage for this application.";
            }

            var note = string.IsNullOrWhiteSpace(form.Note) ? null : form.Note.Trim();
            if (note != null && note.Length > 1000) return "Keep the staff note under 1000 characters.";

            try
            {
                var existingRows = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"application_id=eq.{id}&select=application_id,student_id,room_id,status_id&limit=1");
                var existing = existingRows.FirstOrDefault();
                if (existing == null) return "The application could not be found.";

                if (statusId == Approved && existing.StatusId != Approved && existing.RoomId.HasValue &&
                    await RoomIsFullAsync(existing.RoomId.Value))
                {
                    return "This room is already fully occupied, so the application can't be approved. Decline it or ask the student to choose another room.";
                }

                await _db.UpdateAsync(ApplicationTable, $"application_id=eq.{id}",
                    new { status_id = statusId, staff_note = note });

                // Accepting (or un-accepting) a tenant changes who lives in the room
                if (existing.RoomId.HasValue && (statusId == Approved || existing.StatusId == Approved))
                {
                    await RefreshRoomOccupancyAsync(existing.RoomId.Value);
                }

                if (statusId is Approved or Rejected && existing.StatusId != statusId)
                {
                    var approved = statusId == Approved;
                    var title = approved ? "Application approved" : "Application decision made";
                    var message = approved
                        ? "Your accommodation application has been approved. Sign in to view the next steps."
                        : "A decision has been made on your accommodation application. Sign in to view your application status.";
                    await _notifications.AddForStudentRecordAsync(existing.StudentId, title, message, "application_decision");
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not update application {Id}", id);
                return "We couldn't save the update. Check the Output window in Visual Studio for the reason.";
            }
        }

        // ---------- Room occupancy (approved applications are the tenants) ----------

        private class OccupancyRoomRow
        {
            [JsonPropertyName("room_id")] public Guid Id { get; set; }
            [JsonPropertyName("capacity")] public int? Capacity { get; set; }
        }

        // Writes the tenants' names into room.current_occupant and marks the room
        // occupied once it holds as many tenants as its capacity.
        public async Task RefreshRoomOccupancyAsync(Guid roomId)
        {
            try
            {
                var room = (await _db.SelectAsync<OccupancyRoomRow>(RoomTable,
                    $"room_id=eq.{roomId}&select=room_id,capacity&limit=1")).FirstOrDefault();
                if (room == null) return;

                var tenants = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"room_id=eq.{roomId}&status_id=eq.{Approved}&select=application_id,student_id,room_id,status_id");
                var students = await StudentsAsync(tenants.Select(t => t.StudentId));
                var names = tenants.Select(t => students.TryGetValue(t.StudentId, out var s) && !string.IsNullOrWhiteSpace(s.FullName)
                        ? s.FullName!.Trim() : "Student")
                    .Distinct().ToList();

                var capacity = Math.Max(room.Capacity ?? 1, 1);
                await _db.UpdateAsync(RoomTable, $"room_id=eq.{roomId}", new
                {
                    current_occupant = names.Count == 0 ? null : string.Join(", ", names),
                    availability_status = tenants.Count < capacity
                });

                if (tenants.Count >= capacity)
                {
                    await RejectWaitingApplicationsAsync(roomId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not update occupancy for room {RoomId}", roomId);
            }
        }

        // A tenant who moves out: their application becomes "Moved Out", the bed frees up
        // and they can apply or book viewings again later.
        public async Task<string?> MoveOutAsync(Guid applicationId)
        {
            const int MovedOut = 6;
            try
            {
                var app = (await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"application_id=eq.{applicationId}&select=application_id,student_id,room_id,status_id&limit=1")).FirstOrDefault();
                if (app == null) return "The tenant's application could not be found.";
                if (app.StatusId != Approved) return "Only current tenants can be removed.";

                await _db.UpdateAsync(ApplicationTable, $"application_id=eq.{applicationId}", new
                {
                    status_id = MovedOut,
                    staff_note = $"Moved out on {DateTime.Today:d MMMM yyyy}."
                });

                if (app.RoomId.HasValue) await RefreshRoomOccupancyAsync(app.RoomId.Value);

                await _notifications.AddForStudentRecordAsync(app.StudentId, "You have been checked out",
                    "Management has recorded that you moved out of your room. You're welcome to apply again or book a viewing any time.",
                    "application_decision");
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not move out application {Id}", applicationId);
                return "We couldn't remove the tenant. Check the Output window in Visual Studio for the reason.";
            }
        }

        // A full room can't take anyone else: decline everyone still waiting for it
        private async Task RejectWaitingApplicationsAsync(Guid roomId)
        {
            const int Draft = 5;
            var waiting = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                $"room_id=eq.{roomId}&status_id=in.({Submitted},{UnderReview},{Draft})&select=application_id,student_id,room_id,status_id");

            foreach (var app in waiting)
            {
                await _db.UpdateAsync(ApplicationTable, $"application_id=eq.{app.Id}", new
                {
                    status_id = Rejected,
                    staff_note = "Automatically declined: the room is now fully occupied."
                });
                await _notifications.AddForStudentRecordAsync(app.StudentId, "Room no longer available",
                    "The room you applied for has been filled, so your application was declined. You're welcome to apply for another available room.",
                    "application_decision");
            }
        }

        private async Task<bool> RoomIsFullAsync(Guid roomId)
        {
            var room = (await _db.SelectAsync<OccupancyRoomRow>(RoomTable,
                $"room_id=eq.{roomId}&select=room_id,capacity&limit=1")).FirstOrDefault();
            var tenants = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                $"room_id=eq.{roomId}&status_id=eq.{Approved}&select=application_id");
            return tenants.Count >= Math.Max(room?.Capacity ?? 1, 1);
        }

        // Tenants per room, with their contact details, for Properties & rooms
        public async Task<Dictionary<Guid, List<AdminOccupant>>> GetOccupantsAsync()
        {
            var result = new Dictionary<Guid, List<AdminOccupant>>();
            try
            {
                var tenants = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"status_id=eq.{Approved}&room_id=not.is.null&select=application_id,student_id,room_id,status_id,application_number,created_at");
                var students = await StudentsAsync(tenants.Select(t => t.StudentId));

                foreach (var t in tenants)
                {
                    students.TryGetValue(t.StudentId, out var s);
                    var occupant = new AdminOccupant
                    {
                        ApplicationId = t.Id,
                        StudentId = t.StudentId,
                        Name = string.IsNullOrWhiteSpace(s?.FullName) ? "Student" : s!.FullName!,
                        StudentNumber = s?.StudentNumber ?? "",
                        Phone = s?.PhoneNumber ?? "",
                        Institution = s?.Institution ?? "",
                        Email = await EmailAsync(s?.UserId),
                        Application = t.ApplicationNumber ?? "",
                        Since = t.CreatedAt
                    };
                    if (!result.TryGetValue(t.RoomId!.Value, out var list)) result[t.RoomId.Value] = list = new();
                    list.Add(occupant);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load room occupants");
            }
            return result;
        }

        // ---------- Viewing requests (booking table) ----------

        public async Task<AdminViewingsViewModel> GetViewingsAsync()
        {
            var vm = new AdminViewingsViewModel();

            try
            {
                var rows = await _db.SelectAsync<AdminBookingRow>(BookingTable, "order=created_at.desc&limit=500");
                var rooms = await RoomsAsync(rows.Select(b => b.RoomId));
                var students = await StudentsAsync(rows.Select(b => b.StudentId));

                vm.Items = rows.Select(b =>
                {
                    var name = NameOf(students, b.StudentId);
                    var reference = Ref(b.ReferenceCode, b.Id, "VIEW");

                    return new AdminViewingListItem
                    {
                        Id = b.Id,
                        Reference = reference,
                        Student = name,
                        Room = RoomText(rooms, b.RoomId),
                        RequestedText = DayOf(b.BookingDate),
                        SortKey = Unix(b.BookingDate),
                        StatusKey = BookingKey(b.BookingStatus),
                        StatusLabel = BookingLabel(b.BookingStatus),
                        SearchText = $"{name} {reference}".ToLowerInvariant()
                    };
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load viewing requests");
                vm.LoadFailed = true;
            }

            return vm;
        }

        public async Task<AdminViewingDetailViewModel?> GetViewingDetailAsync(Guid id)
        {
            try
            {
                var rows = await _db.SelectAsync<AdminBookingRow>(BookingTable, $"booking_id=eq.{id}&limit=1");
                var b = rows.FirstOrDefault();
                if (b == null) return null;

                var rooms = await RoomsAsync(new Guid?[] { b.RoomId });
                var students = await StudentsAsync(new[] { b.StudentId });
                students.TryGetValue(b.StudentId, out var s);

                var requested = $"{(b.BookingDate.HasValue ? b.BookingDate.Value.ToString("dd MMMM", Inv) : "-")} - {Clean(b.PreferredTime)}";
                if (!string.IsNullOrWhiteSpace(b.AlternativeTime))
                {
                    requested += $" (alternative: {b.AlternativeTime})";
                }

                var key = BookingKey(b.BookingStatus);

                var vm = new AdminViewingDetailViewModel
                {
                    Id = b.Id,
                    Reference = Ref(b.ReferenceCode, b.Id, "VIEW"),
                    Student = Clean(s?.FullName),
                    Email = await EmailAsync(s?.UserId),
                    Phone = Clean(s?.PhoneNumber),
                    StatusKey = key,
                    StatusLabel = BookingLabel(b.BookingStatus),
                    Room = RoomText(rooms, b.RoomId),
                    StudentMessage = Clean(b.Message),
                    RequestedText = requested,
                    Dates = ViewingOptions.Dates(),
                    Times = ViewingOptions.Times.ToList(),
                    Form = new ViewingResponseForm
                    {
                        Response = key == "confirmed" ? "confirm"
                                 : key == "rescheduled" ? "alternative"
                                 : key == "declined" ? "decline" : "",
                        AltDate = b.StaffAltDate?.ToString("yyyy-MM-dd", Inv),
                        AltTime = b.StaffAltTime,
                        Message = b.StaffMessage
                    }
                };

                vm.History.Add(new HistoryLine
                {
                    Event = "Request submitted",
                    Channel = "Student app",
                    DateText = DayYearOf(b.CreatedAt),
                    Status = "Requested"
                });

                if (b.RespondedAt != null)
                {
                    vm.History.Add(new HistoryLine
                    {
                        Event = "Staff response",
                        Channel = "Staff portal",
                        DateText = DayYearOf(b.RespondedAt),
                        Status = BookingLabel(b.BookingStatus)
                    });
                }

                return vm;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load viewing request {Id}", id);
                return null;
            }
        }

        // Returns an error message, or null when saved.
        public async Task<string?> RespondToViewingAsync(Guid id, ViewingResponseForm form)
        {
            string status;
            string? altDate = null;
            string? altTime = null;

            switch (form.Response)
            {
                case "confirm":
                    status = "Confirmed";
                    break;
                case "decline":
                    status = "Declined";
                    break;
                case "alternative":
                    status = "Rescheduled";
                    if (string.IsNullOrWhiteSpace(form.AltDate) || string.IsNullOrWhiteSpace(form.AltTime))
                    {
                        return "Choose an alternative date and time.";
                    }
                    if (!DateTime.TryParseExact(form.AltDate, "yyyy-MM-dd", Inv, DateTimeStyles.None, out _))
                    {
                        return "Choose a valid alternative date.";
                    }
                    altDate = form.AltDate;
                    altTime = form.AltTime;
                    break;
                default:
                    return "Choose how you want to respond.";
            }

            var message = string.IsNullOrWhiteSpace(form.Message) ? null : form.Message.Trim();
            if (message != null && message.Length > 500) return "Keep the message under 500 characters.";

            try
            {
                await _db.UpdateAsync(BookingTable, $"booking_id=eq.{id}", new
                {
                    booking_status = status,
                    staff_alt_date = altDate,
                    staff_alt_time = altTime,
                    staff_message = message,
                    responded_at = DateTimeOffset.UtcNow
                });
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not save viewing response {Id}", id);
                return "We couldn't save your response. Check the Output window in Visual Studio for the reason.";
            }
        }

        // ---------- Student records ----------

        public async Task<AdminStudentsViewModel> GetStudentsAsync()
        {
            var vm = new AdminStudentsViewModel();

            try
            {
                var apps = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"status_id=in.({Submitted},{UnderReview},{Approved},{Rejected})&order=created_at.desc&limit=1000");
                var rooms = await RoomsAsync(apps.Select(a => a.RoomId));
                var students = await StudentsAsync(apps.Select(a => a.StudentId));

                vm.Items = apps.GroupBy(a => a.StudentId).Select(g =>
                {
                    var latest = g.First();
                    var approved = g.FirstOrDefault(a => a.StatusId == Approved);
                    var current = approved ?? latest;
                    var occupant = approved != null;
                    var name = NameOf(students, g.Key);

                    return new AdminStudentListItem
                    {
                        StudentId = g.Key,
                        Name = name,
                        Status = occupant ? "Current" : latest.StatusId == Rejected ? "Rejected" : "Pending",
                        Room = RoomText(rooms, current.RoomId),
                        RecordKey = occupant ? "occupant" : "applicant",
                        RecordLabel = occupant ? "Occupant" : "Applicant",
                        SearchText = $"{name} {(students.TryGetValue(g.Key, out var st) ? st.StudentNumber : "")}".ToLowerInvariant()
                    };
                }).OrderBy(s => s.Name).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load student records");
                vm.LoadFailed = true;
            }

            return vm;
        }

        public async Task<AdminStudentRecordViewModel?> GetStudentRecordAsync(Guid studentId)
        {
            try
            {
                var students = await StudentsAsync(new[] { studentId });
                if (!students.TryGetValue(studentId, out var s)) return null;

                var apps = await _db.SelectAsync<AdminApplicationRow>(ApplicationTable,
                    $"student_id=eq.{studentId}&status_id=in.({Submitted},{UnderReview},{Approved},{Rejected})&order=created_at.desc");
                var bookings = await _db.SelectAsync<AdminBookingRow>(BookingTable,
                    $"student_id=eq.{studentId}&order=created_at.desc");

                var rooms = await RoomsAsync(apps.Select(a => a.RoomId).Concat(bookings.Select(b => b.RoomId)));

                var approved = apps.FirstOrDefault(a => a.StatusId == Approved);
                var current = approved ?? apps.FirstOrDefault();
                var occupant = approved != null;
                var name = Clean(s.FullName);

                return new AdminStudentRecordViewModel
                {
                    StudentId = studentId,
                    Name = name,
                    Initial = name == "-" ? "?" : char.ToUpperInvariant(name[0]).ToString(),
                    Email = await EmailAsync(s.UserId),
                    Phone = Clean(s.PhoneNumber),
                    Institution = Clean(s.Institution),
                    StudentNumber = Clean(s.StudentNumber),
                    Room = current == null ? "-" : RoomText(rooms, current.RoomId),
                    BadgeLabel = occupant ? "Current student" : "Applicant",
                    Occupancy = occupant ? "Occupant" : "Applicant",
                    Applications = apps.Select(a => new RecordApplicationLine
                    {
                        Id = a.Id,
                        Reference = Ref(a.ApplicationNumber, a.Id, "APP"),
                        Room = RoomText(rooms, a.RoomId),
                        SubmittedText = DayOf(SubmittedOn(a)),
                        Outcome = OutcomeText(a.StatusId)
                    }).ToList(),
                    Viewings = bookings.Select(b => new RecordViewingLine
                    {
                        Id = b.Id,
                        Reference = Ref(b.ReferenceCode, b.Id, "VIEW"),
                        Room = RoomText(rooms, b.RoomId),
                        DateText = DayOf(b.BookingDate),
                        Status = BookingLabel(b.BookingStatus)
                    }).ToList()
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load student record {Id}", studentId);
                return null;
            }
        }
    }
}