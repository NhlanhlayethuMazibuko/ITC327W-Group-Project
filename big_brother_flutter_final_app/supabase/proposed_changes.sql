-- PROPOSED FOR TEAM REVIEW. NOT APPLIED to the shared Supabase project.
-- Table and column names follow the ERD; adjust to the real schema first.
-- Only apply after the ASP.NET developer confirms it does not clash with management access.

-- 1. Create the student row automatically after sign-up (only for self-registered students,
--    identified by the student_number metadata the Flutter app sends).
create or replace function public.handle_new_student() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.raw_user_meta_data ? 'student_number' then
    insert into public.student (student_id, user_id, full_name, student_number)
    values (gen_random_uuid(), new.id,
            coalesce(new.raw_user_meta_data->>'full_name', ''),
            coalesce(new.raw_user_meta_data->>'student_number', ''))
    on conflict do nothing;
  end if;
  return new;
end $$;

drop trigger if exists on_auth_user_created_student on auth.users;
create trigger on_auth_user_created_student
  after insert on auth.users for each row execute function public.handle_new_student();

-- 2. Row Level Security
alter table public.student enable row level security;
alter table public.room enable row level security;
alter table public.room_image enable row level security;
alter table public.accommodation enable row level security;
alter table public.notifications enable row level security;

-- Accommodation catalogue is intended to be visible to signed-in students (read only).
create policy "catalogue read room" on public.room for select to authenticated using (true);
create policy "catalogue read room_image" on public.room_image for select to authenticated using (true);
create policy "catalogue read accommodation" on public.accommodation for select to authenticated using (true);

-- A student sees only their own row. Updates should be limited to approved fields
-- (use a column-level GRANT or a view) so students cannot change protected data.
create policy "student reads own row" on public.student for select to authenticated using (user_id = auth.uid());

-- Notifications: own rows only; students may only mark them read.
create policy "student reads own notifications" on public.notifications for select to authenticated
  using (student_id in (select student_id from public.student where user_id = auth.uid()));

-- Management access must use a trusted role (app_metadata or a role table), never user-editable metadata.
