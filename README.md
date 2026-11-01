# Big Brother Student Accommodation - Flutter app

Stages 2-3 only: foundation and authentication. Home, rooms, applications and the rest are not built yet.

## Setup
1. Copy these files into your Flutter project (or run `flutter create .` here first to generate android/ios folders).
2. Put the logo at `assets/images/logo.png` (a text fallback is used until then).
3. `flutter pub get`
4. Run with your project values (never commit them):
   `flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxx`

## Supabase settings this code expects
- Auth > Email: "Confirm email" ON for the 6-digit verification screen.
- Auth > Email Templates: the "Confirm signup" and "Reset password" templates must show `{{ .Token }}` (the 6-digit code) instead of only a link.
- Full name and student number are saved in auth user metadata for now. Mapping them to your students table needs the approved schema.

## Stage 4 additions
- Bottom navigation, Home, Available Rooms and Unit Details read from Supabase (room, room_image, student, notifications).
- Table names are in `lib/core/config/db_names.dart`. Room images use the `room-images` bucket unless `image_path` is a full URL (override with `--dart-define=ROOM_IMAGE_BUCKET=...`).
- `supabase/proposed_changes.sql` is a PROPOSAL (student auto-create trigger and RLS). It has not been applied.

## Quick configuration (recommended)
1. Copy `env.example.json` to `local.env.json` (already git-ignored) and fill in your real values.
2. Run `flutter run -d chrome --dart-define-from-file=local.env.json`, or press F5 in VS Code and pick "Big Brother (Supabase)".
3. After changing the file, fully stop and restart the app. Hot reload does not re-read these values.

## Full app (all Figma screens)
- Supabase URL and publishable key are built in as defaults in `lib/core/config/app_config.dart` (the publishable key is meant for client apps; data is protected by Row Level Security). `--dart-define` values still override them.
- Run: `flutter pub get` then `flutter run -d chrome`.
- Backend: run `supabase/full_setup.sql` once in the Supabase SQL Editor, then optionally `supabase/sample_data.sql`.
- `supabase/proposed_changes.sql` (Stage 4) is superseded by `full_setup.sql`.
- Needed Supabase Auth settings: email confirmation ON and the Confirm signup / Reset password email templates showing `{{ .Token }}`.
