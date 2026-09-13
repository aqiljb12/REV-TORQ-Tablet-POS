-- REV TORQ POS — fix staff_role_check mismatch
-- Cause: js/admin.js saveStaff() inserts role values 'admin' / 'pos' /
-- 'pomen' / 'stor' (from the "Daftar Staf Baru" dropdown, index.html
-- line ~1216), but the staff_role_check CHECK constraint on
-- public.staff was defined against an older/different set of role
-- values, so any staff-code that maps to one of the newer values
-- (e.g. 'pos') is rejected by Postgres at insert time. The Supabase
-- Auth user is already created by that point (signUp succeeds first),
-- so this also leaves an orphaned auth.users row with no matching
-- public.staff row — see note at the bottom of this file.

-- STEP 1 — run this first (read-only) to see the CURRENT allowed list:
select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid = 'public.staff'::regclass
  and conname = 'staff_role_check';

-- STEP 2 — recreate the constraint so it matches every role value the
-- app actually sends. Includes 'owner' too, since js/core.js,
-- js/admin.js and js/monitacc-dashboard.js all treat 'owner' as a
-- valid admin-tier role elsewhere in the app. Adjust this list if
-- STEP 1 shows other legacy values already stored in existing rows —
-- dropping a value that's in use on an existing row will make this
-- ALTER fail with a constraint violation, which is your signal to add
-- that value to the list below instead of removing it.
alter table public.staff
  drop constraint if exists staff_role_check;

alter table public.staff
  add constraint staff_role_check
  check (role in ('owner','admin','pos','pomen','stor'));

-- CLEANUP — orphaned Auth user from the failed attempt(s):
-- Any staff ID you tried to save while this bug was live (e.g. "PPOS")
-- now has a Supabase Auth account with no public.staff row attached.
-- Retrying with the same ID will fail with "ID staf ... sudah
-- digunakan" because signUp() sees the email as already registered.
-- Go to Supabase Dashboard -> Authentication -> Users, find that
-- staff's email, and delete it there before retrying — this migration
-- does not touch auth.users, since that needs the service role, not
-- the SQL editor's default role.
