-- ============================================================================
-- BIG BROTHER - FULL SUPABASE SETUP (additive, safe to re-run)
-- Paste into Supabase > SQL Editor > New query > Run.
-- Uses "create ... if not exists" and "add column if not exists" so existing
-- tables and data are never dropped. Lines marked CHANGE relax or tighten one
-- existing rule; they are listed in the handover notes.
-- ============================================================================

-- ---------- reference-code sequences ----------
create sequence if not exists public.bb_app_seq;
create sequence if not exists public.bb_vw_seq;
create sequence if not exists public.bb_mnt_seq;
create sequence if not exists public.bb_pay_seq;

-- ---------- tables (ERD names, lowercase) ----------
create table if not exists public.accommodation (
  accommodation_id uuid primary key default gen_random_uuid(),
  name text, description text, address text, vision text, mission text, "values" text
);
create table if not exists public.room (
  room_id uuid primary key default gen_random_uuid(),
  accommodation_id uuid references public.accommodation(accommodation_id),
  room_name text, room_type text, price numeric, capacity int,
  availability_status boolean default true, description text,
  wifi boolean default false, laundry boolean default false, security boolean default false,
  shuttle boolean default false, furniture boolean default false, is_featured boolean default false
);
create table if not exists public.room_image (
  image_id uuid primary key default gen_random_uuid(),
  room_id uuid references public.room(room_id) on delete cascade,
  image_path text
);
create table if not exists public.student (
  student_id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id),
  full_name text, student_number text, phone_number text, date_of_birth date,
  institution text, year_of_study int, nsfas_funded boolean,
  guardian_name text, guardian_email text, guardian_contact text, relationship text
);
create table if not exists public.application_status (
  status_id uuid primary key default gen_random_uuid(),
  status_name text not null
);
create table if not exists public.application (
  application_id uuid primary key default gen_random_uuid(),
  student_id uuid references public.student(student_id),
  room_id uuid references public.room(room_id),
  status_id uuid references public.application_status(status_id),
  application_date date default current_date,
  application_number text
);
create table if not exists public.document (
  document_id uuid primary key default gen_random_uuid(),
  application_id uuid references public.application(application_id) on delete cascade,
  document_type text, file_path text, upload_date timestamptz default now()
);
create table if not exists public.booking (
  booking_id uuid primary key default gen_random_uuid(),
  student_id uuid references public.student(student_id),
  room_id uuid references public.room(room_id),
  booking_date date, booking_status text default 'Pending'
);
create table if not exists public.payment (
  payment_id uuid primary key default gen_random_uuid(),
  booking_id uuid references public.booking(booking_id),
  amount numeric, payment_status text default 'Awaiting Payment',
  payment_date date, payment_reference text, proof_of_payment text
);
create table if not exists public.review (
  review_id uuid primary key default gen_random_uuid(),
  student_id uuid references public.student(student_id),
  rating int check (rating between 1 and 5), comment text,
  created_at timestamptz default now()
);
create table if not exists public.maintenance_requests (
  request_id uuid primary key default gen_random_uuid(),
  student_id uuid references public.student(student_id),
  room_id uuid references public.room(room_id),
  reference_code text, category text, priority text, request_type text,
  photo_path text, description text, status text default 'Pending',
  created_at timestamptz default now()
);
create table if not exists public.notifications (
  notification_id uuid primary key default gen_random_uuid(),
  student_id uuid references public.student(student_id),
  title text, message text, notification_type text,
  is_read boolean default false, created_at timestamptz default now()
);
create table if not exists public.announcements (
  announcement_id uuid primary key default gen_random_uuid(),
  user_id uuid, title text, message text, created_at timestamptz default now()
);

-- ---------- GAP FIXES: columns the Figma screens need that the ERD lacks ----------
alter table public.booking add column if not exists preferred_time text;
alter table public.booking add column if not exists alternative_time text;
alter table public.booking add column if not exists gender text;
alter table public.booking add column if not exists room_type text;
alter table public.booking add column if not exists reference_code text;
alter table public.booking add column if not exists created_at timestamptz default now();
alter table public.booking alter column room_id drop not null;          -- CHANGE: a viewing is for a room type, not one room
alter table public.payment add column if not exists application_id uuid references public.application(application_id);
alter table public.payment add column if not exists due_date date;
alter table public.payment alter column booking_id drop not null;       -- CHANGE: payments belong to applications in the design
alter table public.maintenance_requests alter column room_id drop not null;  -- CHANGE: students have no room allocation yet
do $$ begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='maintenance_requests' and column_name='desciption')
     and not exists (select 1 from information_schema.columns where table_schema='public' and table_name='maintenance_requests' and column_name='description') then
    alter table public.maintenance_requests rename column desciption to description;  -- CHANGE: fixes the ERD typo
  end if;
end $$;

-- Make sure tables that may already exist have every column the app reads
alter table public.student add column if not exists phone_number text;
alter table public.student add column if not exists date_of_birth date;
alter table public.student add column if not exists institution text;
alter table public.student add column if not exists year_of_study int;
alter table public.student add column if not exists nsfas_funded boolean;
alter table public.student add column if not exists guardian_name text;
alter table public.student add column if not exists guardian_email text;
alter table public.student add column if not exists guardian_contact text;
alter table public.student add column if not exists relationship text;
alter table public.room add column if not exists wifi boolean default false;
alter table public.room add column if not exists laundry boolean default false;
alter table public.room add column if not exists security boolean default false;
alter table public.room add column if not exists shuttle boolean default false;
alter table public.room add column if not exists furniture boolean default false;
alter table public.room add column if not exists is_featured boolean default false;

-- ---------- lookup data ----------
insert into public.application_status (status_name)
select v from (values ('Submitted'), ('Under Review'), ('Approved'), ('Rejected')) t(v)
where not exists (select 1 from public.application_status s where s.status_name = t.v);

create table if not exists public.bank_details (
  id uuid primary key default gen_random_uuid(),
  bank_name text, account_holder text, account_number text, branch_code text
);
-- Values copied from the Figma Payment screen. CONFIRM before real use.
insert into public.bank_details (bank_name, account_holder, account_number, branch_code)
select 'FNB (First National Bank)', 'Big Brother Student Accommodation', '8291 0384 7721', '250655'
where not exists (select 1 from public.bank_details);

-- ---------- automatic reference codes ----------
create or replace function public.bb_set_reference() returns trigger language plpgsql as $$
begin
  if tg_table_name = 'application' and coalesce(new.application_number, '') = '' then
    new.application_number := 'BB-APP-' || to_char(now(), 'YYYY') || '-' || lpad(nextval('public.bb_app_seq')::text, 4, '0');
  elsif tg_table_name = 'booking' and coalesce(new.reference_code, '') = '' then
    new.reference_code := 'BB-VW-' || to_char(now(), 'YYMMDD') || '-' || lpad(nextval('public.bb_vw_seq')::text, 4, '0');
  elsif tg_table_name = 'maintenance_requests' and coalesce(new.reference_code, '') = '' then
    new.reference_code := 'BB-MNT-' || to_char(now(), 'YYYY') || '-' || lpad(nextval('public.bb_mnt_seq')::text, 3, '0');
  elsif tg_table_name = 'payment' and coalesce(new.payment_reference, '') = '' then
    new.payment_reference := 'BB-PAY-' || to_char(now(), 'YYYY') || '-' || lpad(nextval('public.bb_pay_seq')::text, 4, '0');
  end if;
  return new;
end $$;

drop trigger if exists bb_ref_application on public.application;
create trigger bb_ref_application before insert on public.application for each row execute function public.bb_set_reference();
drop trigger if exists bb_ref_booking on public.booking;
create trigger bb_ref_booking before insert on public.booking for each row execute function public.bb_set_reference();
drop trigger if exists bb_ref_maintenance on public.maintenance_requests;
create trigger bb_ref_maintenance before insert on public.maintenance_requests for each row execute function public.bb_set_reference();
drop trigger if exists bb_ref_payment on public.payment;
create trigger bb_ref_payment before insert on public.payment for each row execute function public.bb_set_reference();

-- When a student uploads proof, the payment moves to "Pending Verification" automatically.
create or replace function public.bb_payment_proof_status() returns trigger language plpgsql as $$
begin
  if new.proof_of_payment is distinct from old.proof_of_payment and new.proof_of_payment is not null
     and coalesce(new.payment_status, '') in ('', 'Awaiting Payment') then
    new.payment_status := 'Pending Verification';
  end if;
  return new;
end $$;
drop trigger if exists bb_payment_proof on public.payment;
create trigger bb_payment_proof before update on public.payment for each row execute function public.bb_payment_proof_status();

-- ---------- create the student row when someone registers in the app ----------
create or replace function public.handle_new_student() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.raw_user_meta_data ? 'student_number' then
    insert into public.student (user_id, full_name, student_number)
    select new.id, coalesce(new.raw_user_meta_data->>'full_name', ''), coalesce(new.raw_user_meta_data->>'student_number', '')
    where not exists (select 1 from public.student where user_id = new.id);
  end if;
  return new;
end $$;
drop trigger if exists on_auth_user_created_student on auth.users;
create trigger on_auth_user_created_student after insert on auth.users for each row execute function public.handle_new_student();

-- Helper used by the policies below
create or replace function public.bb_my_student_id() returns uuid
language sql stable security definer set search_path = public as $$
  select student_id from public.student where user_id = auth.uid() limit 1
$$;
grant execute on function public.bb_my_student_id() to authenticated;

-- ---------- privacy-safe public reviews (first name only) ----------
create or replace view public.review_public as
select r.review_id, split_part(coalesce(s.full_name, 'Student'), ' ', 1) as first_name, r.rating, r.comment, r.created_at
from public.review r left join public.student s on s.student_id = r.student_id;
grant select on public.review_public to authenticated;

-- ---------- Row Level Security ----------
alter table public.accommodation enable row level security;
alter table public.room enable row level security;
alter table public.room_image enable row level security;
alter table public.student enable row level security;
alter table public.application_status enable row level security;
alter table public.application enable row level security;
alter table public.document enable row level security;
alter table public.booking enable row level security;
alter table public.payment enable row level security;
alter table public.bank_details enable row level security;
alter table public.review enable row level security;
alter table public.maintenance_requests enable row level security;
alter table public.notifications enable row level security;
alter table public.announcements enable row level security;

-- Column-level limits: students can only change the fields they are meant to.
revoke update on public.student from authenticated;
grant update (phone_number, date_of_birth, institution, year_of_study, nsfas_funded, guardian_name, guardian_email, guardian_contact, relationship) on public.student to authenticated;
revoke update on public.payment from authenticated;
grant update (proof_of_payment, payment_date) on public.payment to authenticated;
revoke update on public.notifications from authenticated;
grant update (is_read) on public.notifications to authenticated;

-- Read-only catalogue
drop policy if exists "bb read accommodation" on public.accommodation;
create policy "bb read accommodation" on public.accommodation for select to authenticated using (true);
drop policy if exists "bb read room" on public.room;
create policy "bb read room" on public.room for select to authenticated using (true);
drop policy if exists "bb read room_image" on public.room_image;
create policy "bb read room_image" on public.room_image for select to authenticated using (true);
drop policy if exists "bb read status" on public.application_status;
create policy "bb read status" on public.application_status for select to authenticated using (true);
drop policy if exists "bb read bank" on public.bank_details;
create policy "bb read bank" on public.bank_details for select to authenticated using (true);
drop policy if exists "bb read announcements" on public.announcements;
create policy "bb read announcements" on public.announcements for select to authenticated using (true);

-- Student: own row only
drop policy if exists "bb student select" on public.student;
create policy "bb student select" on public.student for select to authenticated using (user_id = auth.uid());
drop policy if exists "bb student update" on public.student;
create policy "bb student update" on public.student for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Applications: own rows; new ones must start as "Submitted" (students cannot approve themselves)
drop policy if exists "bb application select" on public.application;
create policy "bb application select" on public.application for select to authenticated using (student_id = public.bb_my_student_id());
drop policy if exists "bb application insert" on public.application;
create policy "bb application insert" on public.application for insert to authenticated
  with check (student_id = public.bb_my_student_id()
              and status_id = (select status_id from public.application_status where status_name = 'Submitted' limit 1));

-- Documents: only for own applications
drop policy if exists "bb document select" on public.document;
create policy "bb document select" on public.document for select to authenticated
  using (application_id in (select application_id from public.application where student_id = public.bb_my_student_id()));
drop policy if exists "bb document insert" on public.document;
create policy "bb document insert" on public.document for insert to authenticated
  with check (application_id in (select application_id from public.application where student_id = public.bb_my_student_id()));

-- Viewings (booking)
drop policy if exists "bb booking select" on public.booking;
create policy "bb booking select" on public.booking for select to authenticated using (student_id = public.bb_my_student_id());
drop policy if exists "bb booking insert" on public.booking;
create policy "bb booking insert" on public.booking for insert to authenticated
  with check (student_id = public.bb_my_student_id() and booking_status = 'Pending');

-- Payments: students see their own and may only attach proof
drop policy if exists "bb payment select" on public.payment;
create policy "bb payment select" on public.payment for select to authenticated
  using (application_id in (select application_id from public.application where student_id = public.bb_my_student_id()));
drop policy if exists "bb payment update" on public.payment;
create policy "bb payment update" on public.payment for update to authenticated
  using (application_id in (select application_id from public.application where student_id = public.bb_my_student_id()))
  with check (application_id in (select application_id from public.application where student_id = public.bb_my_student_id()));

-- Reviews: students add their own; everyone reads through review_public
drop policy if exists "bb review insert" on public.review;
create policy "bb review insert" on public.review for insert to authenticated with check (student_id = public.bb_my_student_id());

-- Maintenance
drop policy if exists "bb maintenance select" on public.maintenance_requests;
create policy "bb maintenance select" on public.maintenance_requests for select to authenticated using (student_id = public.bb_my_student_id());
drop policy if exists "bb maintenance insert" on public.maintenance_requests;
create policy "bb maintenance insert" on public.maintenance_requests for insert to authenticated
  with check (student_id = public.bb_my_student_id() and status = 'Pending');

-- Notifications
drop policy if exists "bb notifications select" on public.notifications;
create policy "bb notifications select" on public.notifications for select to authenticated using (student_id = public.bb_my_student_id());
drop policy if exists "bb notifications update" on public.notifications;
create policy "bb notifications update" on public.notifications for update to authenticated
  using (student_id = public.bb_my_student_id()) with check (student_id = public.bb_my_student_id());

-- ---------- Storage buckets ----------
insert into storage.buckets (id, name, public) values
  ('room-images', 'room-images', true),
  ('documents', 'documents', false),
  ('payment-proofs', 'payment-proofs', false),
  ('maintenance-photos', 'maintenance-photos', false)
on conflict (id) do nothing;

drop policy if exists "bb room images read" on storage.objects;
create policy "bb room images read" on storage.objects for select to public using (bucket_id = 'room-images');
drop policy if exists "bb own files insert" on storage.objects;
create policy "bb own files insert" on storage.objects for insert to authenticated
  with check (bucket_id in ('documents', 'payment-proofs', 'maintenance-photos') and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "bb own files select" on storage.objects;
create policy "bb own files select" on storage.objects for select to authenticated
  using (bucket_id in ('documents', 'payment-proofs', 'maintenance-photos') and (storage.foldername(name))[1] = auth.uid()::text);
