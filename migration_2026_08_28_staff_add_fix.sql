-- V38.3: Supabase Auth uses user.id (UUID), not Firebase-style user.uid.
-- REV TORQ POS V38.2
-- Add Staff: no schema change is required.
-- This migration only verifies the UUID-backed staff/company relationship
-- used by the new Add Staff flow. Run in Supabase SQL Editor before deploy.

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='staff' and column_name='company_id'
  ) then
    raise exception 'staff.company_id column is missing';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='staff' and column_name='auth_user_id'
  ) then
    raise exception 'staff.auth_user_id column is missing';
  end if;
end $$;

-- Diagnostic: the logged-in admin row should return a non-null company_id.
-- Replace the UUID below with the admin auth.uid() when checking manually:
-- select id, auth_user_id, company_id, location_id, role, active
-- from public.staff
-- where auth_user_id = '<ADMIN_AUTH_UID>';
