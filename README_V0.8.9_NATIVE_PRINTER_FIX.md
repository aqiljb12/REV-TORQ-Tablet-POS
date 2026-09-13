# REV TORQ POS v0.8.9 — Native APK Printer Fix

Fix utama:
- APK tidak lagi cuba render `rawbt:` sebagai web page.
- `rawbt:` dihantar keluar oleh Android Intent / native JavaScript bridge.
- Printer Settings dalam APK kini tunjuk `ANDROID APK / RAWBT`, bukan Browser Print.
- Button printer APK buka Android Bluetooth Settings, bukan Web Bluetooth.
- TEST PRINT dan TEST PETI guna RawBT / ESC-POS dalam APK.
- Browser/PWA behavior dikekalkan untuk WAB.
- Tiada perubahan Supabase, RLS, invoice, stock, auth, atau checkout data.

Punca bug v0.8.8:
`window.location.href = rawbt:...` berlaku di dalam Android WebView, tetapi MainActivity tidak intercept custom scheme itu. WebView cuba buka `rawbt:` sebagai laman web dan keluarkan `Webpage not available`.
