using BigBrotherAccommodation.Web.Models;

namespace BigBrotherAccommodation.Web.Services
{
    public class NotificationService
    {
        private const string Table = "notification";

        private readonly SupabaseServer _db;
        private readonly ProfileService _profiles;
        private readonly ILogger<NotificationService> _logger;

        public NotificationService(SupabaseServer db, ProfileService profiles, ILogger<NotificationService> logger)
        {
            _db = db;
            _profiles = profiles;
            _logger = logger;
        }

        public async Task AddAsync(Guid studentId, string title, string message, string? linkUrl, string? linkText)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                await InsertAsync(recordId, title, message, "portal");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not create notification");
            }
        }

        public async Task<bool> AddForStudentRecordAsync(Guid studentRecordId, string title, string message, string type)
        {
            try
            {
                await InsertAsync(studentRecordId, title, message, type);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not create notification for student {StudentId}", studentRecordId);
                return false;
            }
        }

        private async Task InsertAsync(Guid studentRecordId, string title, string message, string type)
        {
            await _db.InsertAsync<NotificationRecord>(Table, new
            {
                student_id = studentRecordId,
                title,
                message,
                notification_type = type
            });
        }

        public async Task<List<NotificationRecord>> GetAsync(Guid studentId)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                return await _db.SelectAsync<NotificationRecord>(Table, $"student_id=eq.{recordId}&order=created_at.desc&limit=100");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load notifications");
                return new List<NotificationRecord>();
            }
        }

        public async Task<NotificationRecord?> GetOneAsync(Guid studentId, Guid id)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                var rows = await _db.SelectAsync<NotificationRecord>(Table, $"notification_id=eq.{id}&student_id=eq.{recordId}&limit=1");
                return rows.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not load notification");
                return null;
            }
        }

        public async Task MarkReadAsync(Guid studentId, Guid id)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                await _db.UpdateAsync(Table, $"notification_id=eq.{id}&student_id=eq.{recordId}", new { is_read = true });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not mark notification as read");
            }
        }

        public async Task MarkAllReadAsync(Guid studentId)
        {
            try
            {
                var recordId = await _profiles.ResolveStudentIdAsync(studentId);
                await _db.UpdateAsync(Table, $"student_id=eq.{recordId}&is_read=eq.false", new { is_read = true });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not mark notifications as read");
            }
        }
    }
}