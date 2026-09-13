# REV TORQ POS v0.8.7 – Receipt + WhatsApp

Bug-fix release based on v0.8.6 AUTH_CLOUDFLARE.

- Preserves the AUTH/Cloudflare changes from the supplied package.
- Restores the receipt date fix (no dependency on `dashboardToDate`).
- Canonical checkout now awaits receipt rendering and reports receipt-render errors instead of swallowing them.
- Adds a WhatsApp button to the receipt modal. It shares a text receipt through `wa.me` without requiring a customer phone number.
- Renames the receipt close action to `Selesai`.
- Android WebView hands WhatsApp links to the Android intent resolver / WhatsApp app.
- No database, RLS, RPC, schema, or production-data changes.
