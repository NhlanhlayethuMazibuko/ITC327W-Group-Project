# Payment verification columns

Run this in the Supabase SQL Editor before using admin payment verification:

```sql
alter table public.payment
    add column if not exists verified_against_account text,
    add column if not exists verified_amount numeric(12, 2),
    add column if not exists verified_date date;
```
