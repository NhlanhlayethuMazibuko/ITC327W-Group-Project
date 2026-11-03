-- OPTIONAL: demo rooms taken from the Figma screens so the app is not empty.
-- Run AFTER full_setup.sql. Skips itself if rooms already exist. Delete these rows once real data is added.
insert into public.accommodation (name, description, address)
select 'Big Brother Student Accommodation', 'Safe, affordable and convenient student accommodation.', 'Universitas, Bloemfontein'
where not exists (select 1 from public.accommodation);

insert into public.room (accommodation_id, room_name, room_type, price, capacity, availability_status, description, wifi, laundry, security, shuttle, furniture, is_featured)
select a.accommodation_id, v.*
from (select accommodation_id from public.accommodation limit 1) a
cross join (values
  ('Unit', 'Single room - Furnished',  5500, 1, true, 'A private, comfortable room with a bed, study desk, storage space and access to shared accommodation facilities.', true, true, true, true, true, true),
  ('Unit', 'Sharing room - Furnished', 4500, 2, true, 'A shared, furnished room with beds, study desks and access to shared accommodation facilities.', true, true, true, true, true, true),
  ('Unit', 'Single room',              5500, 1, true, 'A private room with access to shared accommodation facilities.', true, true, true, false, false, false)
) as v(room_name, room_type, price, capacity, availability_status, description, wifi, laundry, security, shuttle, furniture, is_featured)
where not exists (select 1 from public.room);
