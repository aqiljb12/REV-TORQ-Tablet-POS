V38.6.17
Fixed inventory list mismatch: production save writes to Supabase products/stock_balances, while legacy inventory.js list/search/edit read the retired inventory collection.
Canonical list now reads products + stock_balances.
Barcode lookup reads products.
Edit reads products.
No SQL/schema/data reset or migration.
