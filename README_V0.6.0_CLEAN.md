REV TORQ POS v0.6.0 — CLEAN SUPABASE WORKSHOP POS

BASE: REV_TORQ_POS_V38_7_8_BARCODE_LAYOUT_FIXED(2).zip

Changes:
- POS product reader uses Supabase products + stock_balances only.
- Barcode/SKU lookup no longer falls back to Firestore inventory.
- USB/Bluetooth keyboard scanners work through POS search + Enter.
- Camera scanner remains available through existing ZXing UI.
- Accounting/Monitacc navigation and dashboard injection removed from this POS deployment.
- Attendance remains a top-bar shortcut, not a main menu.
- Currency display is RM.
- Existing database/schema/data are not modified by this ZIP.

Important:
- This is a frontend cleanup/base. Production checkout remains the existing canonical RPC layer (rt_post_pos_sale / rt_post_job_pos_sale).
- No database reset/drop/delete is performed.
