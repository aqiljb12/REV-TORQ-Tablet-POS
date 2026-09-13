V38.6.18
The barcode scanner result is now written to #invBarcode before scanner teardown, using the native HTMLInputElement value setter for Safari compatibility. The value is re-applied after teardown/render. The pending value is temporary and cleared after one second.
No database/schema changes.
