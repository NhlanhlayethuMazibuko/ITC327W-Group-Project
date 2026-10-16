# Big Brother Student Accommodation – Flutter Student App

Student-facing mobile app (Flutter + Supabase) matching the Figma frames. Shares one Supabase backend with the ASP.NET management portal.

## Run
```bash
flutter create . --project-name big_brother_student_accommodation   # generates android/ios folders (keeps lib/ & pubspec)
flutter pub get
# Demo mode (no backend, in-memory data):
flutter run
# Live mode:
flutter run --dart-define=SUPABASE_ANON_KEY=<your anon key>
```
Live mode: run `supabase_schema.sql` in the Supabase SQL editor first (tables, RLS, buckets, realtime, demo rooms).
In Supabase Auth settings enable email confirmation and use the 6-digit OTP email template ({{ .Token }}).
Management users get `app_metadata.role = "management"` (set from the dashboard) to pass RLS.

## Screens (lib/)
- `auth.dart` – splash, welcome, login (with error state), forgot password, 6-digit verify, reset password, register
- `home.dart` – bottom-nav shell, home, available rooms, unit details, profile
- `application.dart` – 4-step application form, status tracker (real-time), review & feedback, review submitted
- `viewings.dart` – book a viewing, booking details, submitted (ref code), scheduled viewings, viewing details
- `notifications.dart` – list (All/Unread, Today/Earlier, mark all read) and detail
- `maintenance.dart` – list, new request, submitted, report
- `payment.dart` – bank details + proof-of-payment upload, uploaded confirmation
- `state.dart` – single state/service layer (Supabase auth, DB, storage, realtime, demo fallback)

## Notes
- Put your logo at `assets/logo.png`; a text/icon fallback is used if absent.
- Payments are simulated (bank details + proof upload, verified by management), per the requirements change log.
- Profile also links to Notifications, Maintenance and Payment (these have no entry point in the frames).
- Not run in this environment (no Flutter SDK) – run `flutter analyze` after `flutter pub get` and fix any version-specific warnings.
