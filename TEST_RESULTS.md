# Verification — v0.8.6

Executed 2026-09-13 against this package.

## Passed

- `node --test tests/auth.test.cjs`: 24 passed, 0 failed. Supabase is mocked; no production credentials or database writes used.
- Valid login, exact UID/code binding, inactive/removed/missing/duplicate staff, missing company, empty/unknown role, forged storage/DOM role, logout success and network failure, revoked-user restore, overlapping restore calls, logout during in-flight login, external signout, disabled bootstrap, numeric PIN validation, static modal retention, and forged company/UID context.
- `node tests/verify-package.cjs <original-project-directory>`: 168 scripts compiled, 136 local references checked, 38 files in minimal GitHub upload, matching patched files in root/WAB/APK/upload copies.
- HTML layout outside script tags and all CSS files match original v0.8.5 (ignoring only final trailing whitespace for HTML).
- Minimal upload contains no SQL, keystores, private key blocks or Supabase service-role JWTs detected by the included checks. Pattern scans are not a comprehensive secret audit.
- `npx --yes wrangler@4.131.1 deploy --dry-run` in `UPLOAD_GITHUB`: exit code 0. Assets directory resolved successfully; no actual deployment performed.

## Not verified

- Real Supabase login, database RLS/RPC enforcement, server-side owner bootstrap restrictions, rate limiting, and JWT lifetime.
- Browser end-to-end rendering and production POS transactions, printing, camera/scanning.
- Android APK compilation/signing/device execution. Source only; no compiled APK supplied.
- Live Cloudflare deployment or public URL health.

Do not treat frontend checks as a replacement for server-side authorization.
