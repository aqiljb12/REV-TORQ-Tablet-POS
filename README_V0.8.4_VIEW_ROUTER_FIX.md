# REV TORQ POS Android v0.8.4 — View Router Fix

Fixes the stacked/overlapping pages seen on Android tablet where Dashboard remained visible behind Customers or other views.

Changes:
- Adds local `.hidden` fallback so Android WebView does not depend on Tailwind CDN for page visibility.
- `switchView()` now explicitly hides all `.view-section` elements and shows exactly one target view.
- Removes the legacy `#view-pos + .view-section { display:none }` workaround that could permanently hide the next page after POS.
- Root WAB, WAB_DEPLOY and Android assets are synchronized.
- No database/schema changes.
