# REV TORQ — MASTER SYSTEM

## Admin
Use the existing login/dashboard. The master base is preserved.

## Staff
Staff access is intended for:
- POS
- Job Card
- Inventory
- Customer / Vehicle

## Override Mode
Override is an additive control. It should be enabled only for authorized admin use.

## Important
This build does NOT remove the original application modules, database configuration, or boot/login code.
Dyno is intentionally left out of the new role/navigation layer, but original files are preserved.


## MPT-II Android Direct Print (V38.6.8)

Install/configure RawBT on Android and connect the MPT-II there. REV TORQ then sends raw ESC/POS data through the `rawbt:base64,...` scheme instead of opening the Android PDF save screen. If RawBT is unavailable, the existing Browser Print/PDF fallback remains.
