/// Table names match the live Supabase database shared with the ASP.NET
/// management app. If a name changes there, change it here only.
class Db {
  static const student = 'student';
  static const room = 'room';
  static const roomImage = 'room_image';
  static const notifications = 'notification';
  static const announcements = 'announcement';
  static const applicationStatus = 'application_status';
  static const application = 'application';
  static const document = 'documents';
  static const booking = 'booking';
  static const payment = 'payment';
  static const bankDetails = 'bank_details';
  static const review = 'reviews';
  static const reviewPublic = 'reviews';
  static const maintenance = 'maintenance_requests';
  static const maintenanceUpdate = 'maintenance_update';
}
