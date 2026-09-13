-- REV TORQ V38.1 — Staff Clock In / Clock Out
-- Run this in Supabase SQL Editor (same project used by POS + Customer PWA).

create table if not exists public.staff_attendance (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id),
  staff_id uuid not null references public.staff(id),
  clock_in timestamptz not null default now(),
  clock_out timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_staff_attendance_staff_open
  on public.staff_attendance(staff_id, clock_out);

create index if not exists idx_staff_attendance_company
  on public.staff_attendance(company_id, clock_in desc);

alter table public.staff_attendance enable row level security;

-- Staff can see their own attendance history.
drop policy if exists staff_attendance_self_select on public.staff_attendance;
create policy staff_attendance_self_select
on public.staff_attendance
for select to authenticated
using (
  staff_id in (select id from public.staff where auth_user_id = auth.uid())
);

-- Staff can clock in (insert a new open row) for themselves only.
drop policy if exists staff_attendance_self_insert on public.staff_attendance;
create policy staff_attendance_self_insert
on public.staff_attendance
for insert to authenticated
with check (
  staff_id in (select id from public.staff where auth_user_id = auth.uid())
);

-- Staff can clock out (close their own OPEN row) only — cannot edit a
-- row that is already closed, and cannot touch anyone else's row.
drop policy if exists staff_attendance_self_close on public.staff_attendance;
create policy staff_attendance_self_close
on public.staff_attendance
for update to authenticated
using (
  staff_id in (select id from public.staff where auth_user_id = auth.uid())
  and clock_out is null
)
with check (
  staff_id in (select id from public.staff where auth_user_id = auth.uid())
);

-- Admin/owner can see everyone's attendance within their own company.
-- NOTE: role values assumed lowercase per existing code (js/core.js) —
-- 'owner' / 'super_admin' / 'admin'. Adjust this list if your actual
-- staff.role values differ.
drop policy if exists staff_attendance_admin_select on public.staff_attendance;
create policy staff_attendance_admin_select
on public.staff_attendance
for select to authenticated
using (
  exists (
    select 1 from public.staff s
    where s.auth_user_id = auth.uid()
      and s.company_id = staff_attendance.company_id
      and s.role in ('owner','super_admin','admin')
  )
);
