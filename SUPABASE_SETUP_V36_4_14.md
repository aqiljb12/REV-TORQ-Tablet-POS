# REV TORQ V36.4.14 — Supabase

Project: existing REV TORQ Supabase project.

## Applied migrations
1. `monitacc_mobile_dashboard_role_protection`
2. `lock_admin_override_insert_to_admin`

## New RPCs
- `rt_my_staff_id()`
- `rt_is_admin()`
- `rt_admin_dashboard(p_start, p_end)`

## Financial rule
P&L = Sales - historical COGS - Operating Expenses.

COGS source:
`stock_movements.movement_type = SALE` using `unit_cost` recorded at the time of stock movement.

## Role visibility
Admin/Owner:
- Dashboard
- P&L / Reports
- Expenses
- Audit
- Override
- Staff
- Settings
- all workshop modules

POS staff:
- POS operational screen
- own invoice/payment history only
- cash opening/closing through the existing RPCs

Mechanic/Pomen:
- Job Card
- Inventory operational screens

## Important
No existing business tables were dropped or reset.
