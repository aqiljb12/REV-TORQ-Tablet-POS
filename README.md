# REV TORQ Tablet POS v0.8.6

Static WAB frontend with Supabase authentication. Android source is in the full ZIP, not this minimal web upload.

Cloudflare Worker: `rev-torq-tablet-pos`

- Root directory: `/`
- Build command: empty
- Deploy command: `npx wrangler@4.131.1 deploy`
- Asset directory: `./WAB_DEPLOY` (configured in `wrangler.jsonc`)

At repository root keep this README, `wrangler.jsonc`, and `WAB_DEPLOY/` together.
No npm build or Android/Gradle build is needed for the website.

## Security scope

Removed client override password, unsafe identity fallback and duplicate auth flow.
Uses verified Auth user plus exact active staff mapping. Profile cache is not authentication.
Client owner provisioning is disabled. Existing accounts and database are unchanged.
Database RLS/RPC authorization, rate limiting and server bootstrap restrictions require separate review.
Mock auth tests passed in the full package; live account login and Cloudflare deployment have not been verified.
No secrets belong in this public repository. The configured Supabase key is a publishable frontend key.
