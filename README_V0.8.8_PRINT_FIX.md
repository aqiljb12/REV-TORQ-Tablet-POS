# REV TORQ POS v0.8.8 – Receipt Print Fix

- Fixed `Cetak` appearing to do nothing in desktop/browser mode.
- Browser printing now calls `window.print()` directly from the receipt modal instead of opening a new popup window.
- Existing `@media print` rules already isolate `#printArea`, so only the receipt is printed.
- Android + RawBT direct thermal printing remains unchanged and is still attempted first.
- Synced Cloudflare `WAB_DEPLOY/index.html` receipt actions with v0.8.7: Cetak + WhatsApp + Selesai.
- No database, RLS, RPC, schema, checkout, stock, invoice, or payment changes.
