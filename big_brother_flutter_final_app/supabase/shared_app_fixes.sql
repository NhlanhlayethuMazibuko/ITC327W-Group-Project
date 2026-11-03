-- Makes the live database work the same for the Flutter app (publishable key + RLS)
-- and the ASP.NET site (service key). Safe to run more than once.

-- 1. New sign-ups: the web sends first_name/last_name, the app sends full_name.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path to 'public' as $$
declare
  v_name text := coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
                          trim(concat_ws(' ', new.raw_user_meta_data ->> 'first_name',
                                              new.raw_user_meta_data ->> 'last_name')), '');
begin
  insert into public.users (user_id, full_name, email, role)
  values (new.id, v_name, new.email, 'student');

  insert into public.student (user_id, full_name, student_number)
  values (new.id, v_name, new.raw_user_meta_data ->> 'student_number')
  on conflict (user_id) do nothing;

  return new;
end $$;

-- Fill in names that the old trigger left blank
update public.student s
   set full_name = trim(concat_ws(' ', u.raw_user_meta_data ->> 'first_name', u.raw_user_meta_data ->> 'last_name'))
  from auth.users u
 where u.id = s.user_id and coalesce(s.full_name, '') = ''
   and coalesce(u.raw_user_meta_data ->> 'first_name', '') <> '';
update public.users p
   set full_name = s.full_name
  from public.student s
 where s.user_id = p.user_id and coalesce(p.full_name, '') = '' and coalesce(s.full_name, '') <> '';

-- 2. Reference numbers the app reads back after inserting (the web sets its own).
create sequence if not exists public.bb_app_seq;
create sequence if not exists public.bb_mnt_seq;

create or replace function public.bb_set_application_number()
returns trigger language plpgsql as $$
begin
  if coalesce(new.application_number, '') = '' then
    new.application_number := 'BB-APP-' || to_char(now(), 'YYMMDD') || '-' || lpad(nextval('public.bb_app_seq')::text, 4, '0');
  end if;
  return new;
end $$;
drop trigger if exists bb_ref_application on public.application;
create trigger bb_ref_application before insert on public.application
  for each row execute function public.bb_set_application_number();

create or replace function public.bb_set_maintenance_reference()
returns trigger language plpgsql as $$
begin
  if coalesce(new.reference_code, '') = '' then
    new.reference_code := 'BB-MNT-' || to_char(now(), 'YYMMDD') || '-' || lpad(nextval('public.bb_mnt_seq')::text, 4, '0');
  end if;
  return new;
end $$;
drop trigger if exists bb_ref_maintenance on public.maintenance_requests;
create trigger bb_ref_maintenance before insert on public.maintenance_requests
  for each row execute function public.bb_set_maintenance_reference();

-- 3. Storage: the existing rules cover buckets nothing uses (documents, payments,
--    maintenance). Both apps use these three, foldered by student_id.
drop policy if exists "students read own app files" on storage.objects;
create policy "students read own app files" on storage.objects for select to authenticated
  using (bucket_id in ('application-documents', 'payment-proofs', 'maintenance-photos')
         and ((storage.foldername(name))[1] = public.my_sid()::text or public.is_mgmt()));
drop policy if exists "students upload own app files" on storage.objects;
create policy "students upload own app files" on storage.objects for insert to authenticated
  with check (bucket_id in ('application-documents', 'payment-proofs', 'maintenance-photos')
              and (storage.foldername(name))[1] = public.my_sid()::text);

-- 4. Maintenance: remove the rule that let anyone read, change or delete every
--    request, and the ones comparing student_id to the login id (they differ).
drop policy if exists "Public Insert Maintenance" on public.maintenance_requests;
drop policy if exists "Students can insert own maintenance" on public.maintenance_requests;
drop policy if exists "Students can view own maintenance" on public.maintenance_requests;
drop policy if exists "Students insert own maintenance" on public.maintenance_requests;
drop policy if exists "Students view own maintenance" on public.maintenance_requests;
-- ("own maint" and "mgmt all" remain)

drop policy if exists "student read own updates" on public.maintenance_update;
create policy "student read own updates" on public.maintenance_update for select
  using (exists (select 1 from public.maintenance_requests r
                 where r.request_id = maintenance_update.request_id and r.student_id = public.my_sid()));

-- 5. users: these rules let anyone edit any profile, including role, which
--    is_admin() trusts. Only the signup trigger and the service key write here.
drop policy if exists "Allow all profiles operations" on public.users;
drop policy if exists "Allow all profiles" on public.users;
drop policy if exists "Allow public insert to profiles" on public.users;
drop policy if exists "Allow public read profiles" on public.users;
drop policy if exists "Allow public update profiles" on public.users;
drop policy if exists "Public Insert Profiles" on public.users;
drop policy if exists "Public Read Profiles" on public.users;
drop policy if exists "Public Update Profiles" on public.users;
drop policy if exists "own user read" on public.users;
create policy "own user read" on public.users for select using (user_id = auth.uid());
drop policy if exists "mgmt all" on public.users;
create policy "mgmt all" on public.users for all using (public.is_mgmt()) with check (public.is_mgmt());

-- 6. payment: students may attach proof (status -> awaiting_verification) but not
--    verify, re-price or delete a payment. The website's service key and
--    management are not limited.
create or replace function public.bb_guard_payment()
returns trigger language plpgsql as $$
begin
  if coalesce(auth.role(), '') not in ('authenticated', 'anon') or public.is_mgmt() then
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    raise exception 'Payments can only be removed by management' using errcode = '42501';
  end if;

  if tg_op = 'INSERT' then
    if coalesce(new.payment_status, 'pending') not in ('pending', 'preference_saved', 'awaiting_verification')
       or new.verified_amount is not null or new.verified_date is not null or new.verified_against_account is not null then
      raise exception 'Only management can verify payments' using errcode = '42501';
    end if;
    return new;
  end if;

  if lower(coalesce(old.payment_status, '')) in ('verified', 'paid') then
    raise exception 'This payment is already verified' using errcode = '42501';
  end if;
  if new.payment_status is distinct from old.payment_status and new.payment_status <> 'awaiting_verification' then
    raise exception 'Only management can change a payment status' using errcode = '42501';
  end if;
  if new.amount is distinct from old.amount
     or new.application_id is distinct from old.application_id
     or new.due_date is distinct from old.due_date
     or new.payment_reference is distinct from old.payment_reference
     or new.verified_amount is distinct from old.verified_amount
     or new.verified_date is distinct from old.verified_date
     or new.verified_against_account is distinct from old.verified_against_account then
    raise exception 'Only management can change payment details' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists bb_guard_payment on public.payment;
create trigger bb_guard_payment before insert or update or delete on public.payment
  for each row execute function public.bb_guard_payment();

-- 7. bank_details: one row that the app shows on the payment screen.
--    Management fills it in (the website still reads its own copy from settings).
create table if not exists public.bank_details (
  bank_details_id uuid primary key default gen_random_uuid(),
  account_holder text,
  bank_name text,
  account_number text,
  branch_code text,
  updated_at timestamptz default now()
);
alter table public.bank_details enable row level security;
drop policy if exists "students read bank details" on public.bank_details;
create policy "students read bank details" on public.bank_details for select to authenticated using (true);
drop policy if exists "mgmt all" on public.bank_details;
create policy "mgmt all" on public.bank_details for all using (public.is_mgmt()) with check (public.is_mgmt());

-- 8. One meaning of "admin": the website marks admins with app_metadata.user_role = 'admin',
--    the rules expected app_metadata.role = 'management'. Accept both everywhere.
create or replace function public.is_mgmt()
returns boolean language sql stable as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') = 'management'
      or coalesce(auth.jwt() -> 'app_metadata' ->> 'user_role', '') = 'admin'
$$;
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path to 'public' as $$
  select public.is_mgmt() or exists (select 1 from public.users where user_id = auth.uid() and role = 'admin')
$$;

-- 9. Old storage rules for buckets neither app uses (the buckets themselves are kept).
drop policy if exists "students read own files" on storage.objects;
drop policy if exists "students upload own files" on storage.objects;

-- 10. Give old applications without a number one in the same format.
update public.application
   set application_number = 'BB-APP-' || to_char(coalesce(created_at, now()), 'YYMMDD') || '-' || lpad(nextval('public.bb_app_seq')::text, 4, '0')
 where coalesce(application_number, '') = '';

-- 11. maintenance_requests.student_id pointed at the login id (auth.users), while
--     every other table and both apps use student.student_id. Inserts for anyone
--     whose two ids differ failed with 409. Move old rows over, then link to student.
do $$
declare c text;
begin
  for c in select conname from pg_constraint
           where conrelid = 'public.maintenance_requests'::regclass and contype = 'f'
             and conkey = array[(select attnum from pg_attribute
                                 where attrelid = 'public.maintenance_requests'::regclass and attname = 'student_id')]
  loop
    execute format('alter table public.maintenance_requests drop constraint %I', c);
  end loop;
end $$;
update public.maintenance_requests m
   set student_id = s.student_id
  from public.student s
 where m.student_id = s.user_id and s.student_id <> s.user_id;
alter table public.maintenance_requests
  add constraint maintenance_requests_student_id_fkey foreign key (student_id) references public.student (student_id);

-- 12. Tenants = students with an approved application. Only they report maintenance
--     and read announcements.
create or replace function public.bb_is_tenant()
returns boolean language sql stable security definer set search_path to 'public' as $$
  select exists (select 1 from public.application where student_id = public.my_sid() and status_id = 3)
$$;

drop policy if exists "own maint" on public.maintenance_requests;
drop policy if exists "own maint read" on public.maintenance_requests;
create policy "own maint read" on public.maintenance_requests for select using (student_id = public.my_sid());
drop policy if exists "tenant maint insert" on public.maintenance_requests;
create policy "tenant maint insert" on public.maintenance_requests for insert
  with check (student_id = public.my_sid() and public.bb_is_tenant());

drop policy if exists "public read" on public.announcement;
drop policy if exists "tenants read announcements" on public.announcement;
create policy "tenants read announcements" on public.announcement for select using (public.bb_is_tenant() or public.is_mgmt());

-- 13. Applications: students can read their own, apply as Submitted/Draft, and edit
--     or withdraw only before review starts (they could previously set any status).
drop policy if exists "own app" on public.application;
drop policy if exists "own app read" on public.application;
create policy "own app read" on public.application for select using (student_id = public.my_sid());
drop policy if exists "own app insert" on public.application;
create policy "own app insert" on public.application for insert
  with check (student_id = public.my_sid() and status_id in (1, 5));
drop policy if exists "own app change" on public.application;
create policy "own app change" on public.application for update
  using (student_id = public.my_sid() and status_id in (1, 5))
  with check (student_id = public.my_sid() and status_id in (1, 5));
drop policy if exists "own app withdraw" on public.application;
create policy "own app withdraw" on public.application for delete
  using (student_id = public.my_sid() and status_id in (1, 5));

-- Let students tidy up their own files when they replace or withdraw documents.
drop policy if exists "students delete own app files" on storage.objects;
create policy "students delete own app files" on storage.objects for delete to authenticated
  using (bucket_id in ('application-documents', 'payment-proofs', 'maintenance-photos')
         and (storage.foldername(name))[1] = public.my_sid()::text);

-- 14. Tenants (approved application) can't apply again or book viewings until
--     management records that they moved out (application status 6, "Moved Out").
insert into public.application_status (status_id, status_name) values (6, 'Moved Out')
  on conflict (status_id) do nothing;

drop policy if exists "own app insert" on public.application;
create policy "own app insert" on public.application for insert
  with check (student_id = public.my_sid() and status_id in (1, 5) and not public.bb_is_tenant());

drop policy if exists "tenants cannot book viewings" on public.booking;
create policy "tenants cannot book viewings" on public.booking as restrictive for insert to authenticated
  with check (not public.bb_is_tenant() or public.is_mgmt());

-- 15. Full or unavailable rooms can't be applied for.
drop policy if exists "own app insert" on public.application;
create policy "own app insert" on public.application for insert
  with check (student_id = public.my_sid() and status_id in (1, 5) and not public.bb_is_tenant()
              and (room_id is null or exists (select 1 from public.room r
                                              where r.room_id = application.room_id and r.availability_status)));

-- 16. Rooms can be hidden from the website and app listings (admin "Listing" option).
--     The old test rooms stay in the table because applications and viewings refer to them.
alter table public.room add column if not exists is_listed boolean not null default true;
update public.room set is_listed = false
 where room_id in ('616c602b-51d7-4d99-8265-b5922002305b',   -- "Unit" (Single Room)
                   '97b413b2-8d4a-480b-b269-c4c3e0b1993a',   -- "Unit" (Sharing Room)
                   '86457bae-f47f-4a11-90cf-6f299e9214e6');  -- "Room 22"
