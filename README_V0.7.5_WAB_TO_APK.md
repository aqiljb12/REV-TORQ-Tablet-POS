# REV TORQ POS Android v0.7.5 — WAB → APK

This build wraps the supplied REV TORQ WAB source as an Android WebView app.

## UI / navigation policy
- WAB UI is retained as the visual/function source.
- Backend, Staff, Override and Audit are hidden from the main sidebar and opened from Tetapan Sistem.
- Reports / P&L is removed from the user-facing navigation.
- Expenses / Accounting is not exposed in this POS APK because accounting is a separate app.
- Dyno is not exposed in this POS APK.

## POS cash drawer
The supplied WAB already contains the live cash drawer flow:
- Modal Awal / Opening Float
- Cash In
- Cash Out
- Closing / Kira Baki
- Expected amount vs actual physical count
- Difference (lebih/kurang/seimbang)

Cash drawer operations call the existing WAB RPCs:
`rt_cash_open`, `rt_cash_move`, `rt_cash_close`.

## Zobaze reference
Zobaze POS was inspected only as a UX/architecture reference for sale flow concepts such as cart, payment, amount received/change and receipt state. No Zobaze code/assets/branding are included.

## Android
Open this folder in Android Studio and run on a device/tablet. Internet permission is required because the WAB currently loads Supabase/CDN resources.
