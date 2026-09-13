-- REV TORQ POS v0.6.3
-- Login bootstrap fix only. No table reset, no data deletion.
-- get_staff_login_email is intentionally callable before authentication.
-- Keep the function SECURITY DEFINER and do not expose any sensitive columns.

REVOKE ALL ON FUNCTION public.get_staff_login_email(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_staff_login_email(text) FROM anon;
REVOKE ALL ON FUNCTION public.get_staff_login_email(text) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.get_staff_login_email(text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_staff_login_email(text) TO authenticated;

-- If the deployed function signature uses varchar instead of text, apply the
-- equivalent GRANT to that exact signature in Supabase SQL Editor.
