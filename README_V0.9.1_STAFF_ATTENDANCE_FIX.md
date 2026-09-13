# REV TORQ POS v0.9.1 — Staff Attendance Fix

Fixes the dashboard attendance error:

`column staff.full_name does not exist`

The production `public.staff` schema uses the column `name`, not `full_name`.
All deploy targets now query `id, staff_code, name, company_id, active` and render `staff.name`.

Updated copies:
- `WAB_DEPLOY/js/rt-pos-attendance.js`
- `js/rt-pos-attendance.js`
- `UPLOAD_GITHUB/WAB_DEPLOY/js/rt-pos-attendance.js`
- `app/src/main/assets/js/rt-pos-attendance.js`

No database migration is required for this fix. Existing Supabase schema/RLS is unchanged.
