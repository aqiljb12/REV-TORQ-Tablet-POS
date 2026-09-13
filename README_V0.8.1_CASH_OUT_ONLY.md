# REV TORQ v0.8.1 — CASH OUT ONLY

Money Out dalam POS kini khusus untuk pergerakan tunai Cash Drawer sahaja.

- Buang kategori accounting daripada skrin Money Out: Supplier Purchases, Staff Salary, Rental, Utility Bill, Owner Salary, EPF/SOCSO, Self Billed.
- Form baru: Jumlah Keluar, Sebab ringkas, Nota, staff login automatik.
- Simpan melalui RPC `rt_cash_move` dengan `CASH_OUT`.
- Cash drawer mesti OPEN.
- History membaca `cash_movements` jenis `CASH_OUT`.
- Tiada migration / reset database.
- Accounting penuh kekal untuk aplikasi Accounting berasingan.
