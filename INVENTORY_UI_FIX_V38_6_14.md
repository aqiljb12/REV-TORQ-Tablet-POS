V38.6.14
Fixed Safari ReferenceError: openInventoryPage was referenced as an unscoped lexical variable before the controller exposed it on window.
Inventory routing now uses window.openInventoryPage/window.closeInventoryPage with safe fallback.
No Supabase schema/data changes.
