-- Big Brother Student Accommodation - shared Supabase schema (run in SQL editor)
create extension if not exists "pgcrypto";

create table accommodation (accommodation_id uuid primary key default gen_random_uuid(), name text, description text, address text, vision text, mission text, "values" text);
create table room (
  room_id uuid primary key default gen_random_uuid(), accommodation_id uuid references accommodation,
  room_name text, room_type text, price numeric, capacity int, availability_status bool default true, description text,
  wifi bool default true, laundry bool default true, security bool default true, shuttle bool default true, furniture bool default true, is_featured bool default false);
create table room_image (image_id uuid primary key default gen_random_uuid(), room_id uuid references room on delete cascade, image_path text);
create table student (
  student_id uuid primary key default gen_random_uuid(), user_id uuid unique references auth.users on delete cascade,
  full_name text, student_number text, phone_number text, date_of_birth date, institution text, year_of_study text, nsfas_funded bool,
  guardian_name text, guardian_email text, guardian_contact text, relationship text);
create table application_status (status_id serial primary key, status_name text unique);
insert into application_status(status_name) values ('Submitted'),('Under Review'),('Approved'),('Rejected');
create table application (
  application_id uuid primary key default gen_random_uuid(), student_id uuid references student, room_id uuid references room,
  status_id int references application_status, application_number text unique, application_date date default current_date, created_at timestamptz default now());
create table document (document_id uuid primary key default gen_random_uuid(), application_id uuid references application on delete cascade, document_type text, file_path text, upload_date timestamptz default now());
create table booking (  -- room viewing requests
  booking_id uuid primary key default gen_random_uuid(), student_id uuid references student, room_id uuid references room,
  reference_code text, booking_date date, preferred_time text, alternative_time text, room_type text, booking_status text default 'Pending', created_at timestamptz default now());
create table payment (  -- simulated: proof of payment verified by management
  payment_id uuid primary key default gen_random_uuid(), application_id uuid references application, amount numeric, payment_method text,
  payment_status text default 'Pending Verification', payment_date date, payment_reference text, proof_of_payment text);
create table review (review_id uuid primary key default gen_random_uuid(), student_id uuid references student, rating int check (rating between 1 and 5), comment text, created_at timestamptz default now());
create table maintenance_requests (
  request_id uuid primary key default gen_random_uuid(), student_id uuid references student, room_id uuid references room,
  reference_code text, category text, priority text, request_type text, description text, photo_path text, status text default 'Pending', created_at timestamptz default now());
create table notification (notification_id uuid primary key default gen_random_uuid(), student_id uuid references student on delete cascade, title text, message text, notification_type text, is_read bool default false, created_at timestamptz default now());
create table announcement (announcement_id uuid primary key default gen_random_uuid(), user_id uuid, title text, message text, created_at timestamptz default now());

-- create a student row when a user registers (name + student number come from signUp metadata)
create or replace function handle_new_user() returns trigger language plpgsql security definer as $$
begin
  insert into student(user_id, full_name, student_number) values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'student_number');
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();

-- Row-Level Security: students see only their own data; management = app_metadata.role = 'management'
create or replace function is_mgmt() returns bool language sql stable as $$ select coalesce(auth.jwt()->'app_metadata'->>'role','') = 'management' $$;
create or replace function my_sid() returns uuid language sql stable security definer as $$ select student_id from student where user_id = auth.uid() $$;

do $$ declare t text; begin
  foreach t in array array['accommodation','room','room_image','student','application_status','application','document','booking','payment','review','maintenance_requests','notification','announcement'] loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy "mgmt all" on %I for all using (is_mgmt()) with check (is_mgmt())', t);
  end loop; end $$;

create policy "public read" on accommodation for select using (true);
create policy "public read" on room for select using (true);
create policy "public read" on room_image for select using (true);
create policy "public read" on application_status for select using (true);
create policy "public read" on announcement for select using (true);
create policy "read reviews" on review for select using (auth.role() = 'authenticated');
create policy "own student" on student for select using (user_id = auth.uid());
create policy "own student upd" on student for update using (user_id = auth.uid());
create policy "own app" on application for all using (student_id = my_sid()) with check (student_id = my_sid());
create policy "own docs" on document for all using (application_id in (select application_id from application where student_id = my_sid())) with check (application_id in (select application_id from application where student_id = my_sid()));
create policy "own booking" on booking for all using (student_id = my_sid()) with check (student_id = my_sid());
create policy "own payment" on payment for all using (application_id in (select application_id from application where student_id = my_sid())) with check (application_id in (select application_id from application where student_id = my_sid()));
create policy "own review" on review for insert with check (student_id = my_sid());
create policy "own maint" on maintenance_requests for all using (student_id = my_sid()) with check (student_id = my_sid());
create policy "own notif" on notification for select using (student_id = my_sid());
create policy "own notif upd" on notification for update using (student_id = my_sid());

-- Realtime for live status updates
alter publication supabase_realtime add table application, booking, notification, maintenance_requests;

-- Storage buckets (documents / payments / maintenance private; room-images public)
insert into storage.buckets(id,name,public) values ('documents','documents',false),('payments','payments',false),('maintenance','maintenance',false),('room-images','room-images',true) on conflict do nothing;
create policy "students upload own files" on storage.objects for insert to authenticated with check (bucket_id in ('documents','payments','maintenance') and (storage.foldername(name))[1] = my_sid()::text);
create policy "students read own files" on storage.objects for select to authenticated using (bucket_id in ('documents','payments','maintenance') and ((storage.foldername(name))[1] = my_sid()::text or is_mgmt()));
create policy "public room images" on storage.objects for select using (bucket_id = 'room-images');

-- Demo data
insert into accommodation(name,address) values ('Big Brother Student Accommodation','Universitas, Bloemfontein');
insert into room(room_name,room_type,price,capacity,description,is_featured) values
 ('Unit','1-Bedroom Apartment',4500,1,'A private, comfortable room with a bed, study desk, storage space and access to shared accommodation facilities.',true),
 ('Unit','2-Bedroom Apartment',4500,2,'Shared two-bedroom apartment with study desks and storage.',true),
 ('Unit','Single with Balcony',4500,1,'Single room with a private balcony.',true);
