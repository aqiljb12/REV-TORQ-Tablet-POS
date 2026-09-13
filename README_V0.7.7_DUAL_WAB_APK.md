# REV TORQ POS Android v0.7.7 — DUAL WAB + APK

Build ini disediakan supaya WAB browser dan APK Android boleh digunakan serentak pada database Supabase production yang sama.

## Cara kerja
- WAB dan APK mempunyai login/session local masing-masing.
- Kedua-duanya membaca dan menulis company/location/produk/job/invoice yang sama.
- Setiap client diberi identity local berasingan: `REV-WAB-*` atau `REV-APK-*`.
- Bila app kembali focus/online, modul akan refresh POS, Inventory, Job Cards dan status cash drawer jika loader tersedia.
- Tiada database kedua, tiada reset, tiada DROP, tiada data production dipadam.

## Cash drawer
Current production RPC `rt_cash_open` menerima `drawer_code`, tetapi `rt_cash_move` dan `rt_cash_close` tidak menerima drawer code. Oleh itu build ini sengaja menggunakan SATU drawer canonical `MAIN` untuk WAB + APK pada kaunter yang sama. Ini mengelakkan dua closing tunai yang bercanggah.

Jika kemudian mahu dua peti fizikal berasingan (contoh KAUNTER-1 dan KAUNTER-2), database RPC perlu dinaik taraf secara terkawal untuk menerima `drawer_code`/`device_id` pada move dan close. Jangan hardcode dua drawer dari frontend sahaja.

## Test yang perlu dibuat
1. Login WAB dan APK menggunakan staff sah.
2. Pastikan produk/stock sama pada kedua-dua client.
3. Buka cash drawer MAIN sekali sahaja.
4. Buat satu sale melalui APK.
5. Kembali/focus WAB dan semak invoice/stock berubah.
6. Buat stock update melalui WAB dan focus APK, semak data refresh.
7. Closing cash dibuat sekali pada drawer MAIN.
