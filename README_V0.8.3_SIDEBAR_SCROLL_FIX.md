# REV TORQ v0.8.3 — Sidebar Scroll Fix

Fix targeted at tablet/Android sidebar navigation:
- Sidebar is locked to viewport height without allowing its outer container to swallow touch scroll.
- `#mainNav` is now the dedicated vertical scroll area.
- Adds `min-height: 0`, `overflow-y: auto`, `touch-action: pan-y` and iOS/Android momentum scrolling.
- Brand, profile and logout stay fixed while the menu list scrolls.
- Applied to root WAB, `WAB_DEPLOY`, and Android WebView assets.
- No database/schema changes.
