# REV TORQ POS v0.9.0 — STAFF RECEIPT REPRINT

## Perubahan
- Tambah butang **Resit / Print Semula** terus dalam POS; tidak perlu masuk `ADMIN ONLY`.
- Role `owner/admin/super_admin/manager/staff/pos/cashier` boleh cari resit mengikut invoice, customer, telefon atau plate.
- Reprint memuat semula invoice, invoice_items, payment, juruwang, customer dan vehicle dari Supabase.
- Resit reprint ditanda **SALINAN / REPRINT**, masa reprint dan staff yang membuat reprint.
- Setiap cubaan print semula yang berjaya dihantar ke printer/browser direkod dalam `audit_logs` sebagai `RECEIPT_REPRINT`.
- `VOID` kekal Admin sahaja.
- RLS invoice/payment tidak dilonggarkan; akses staff dibuat melalui RPC SECURITY DEFINER yang semak staff aktif + company + role.
- Checkout, stok, payment dan invoice asal tidak diubah.

## Supabase
Migration `migration_2026_09_13_staff_receipt_reprint.sql` telah direka sebagai additive migration.
