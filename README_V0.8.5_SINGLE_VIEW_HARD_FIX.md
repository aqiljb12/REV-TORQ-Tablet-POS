# REV TORQ v0.8.5 — Single View Hard Fix

- Native `hidden` + inline `display:none!important` used for inactive pages.
- Only one `.view-section` can be visible at a time.
- MutationObserver re-hides legacy pages if old modules alter classes/styles.
- Re-applies active route after async view loaders complete.
- Inventory dedicated form now uses the same exclusive router.
- No database/schema changes.
