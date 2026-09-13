-- REV TORQ additive migration: Monitacc-style mobile dashboard + financial role protection
-- IMPORTANT: does not delete or reset business data.

create or replace function public.rt_my_staff_id()
returns uuid
language sql stable security definer set search_path=public
as $$
  select s.id from public.staff s
  where s.auth_user_id = auth.uid()
    and s.active = true
    and s.removed_from_active_list = false
  limit 1;
$$;

grant execute on function public.rt_my_staff_id() to authenticated;

create or replace function public.rt_is_admin()
returns boolean
language sql stable security definer set search_path=public
as $$
  select lower(coalesce(s.role,'')) in ('owner','admin','super_admin','manager')
  from public.staff s
  where s.auth_user_id = auth.uid()
    and s.active = true
    and s.removed_from_active_list = false
  limit 1;
$$;

grant execute on function public.rt_is_admin() to authenticated;

-- Admin-only financial dashboard. SECURITY DEFINER is intentional; the function
-- performs its own role check so staff cannot bypass the UI by calling the RPC.
create or replace function public.rt_admin_dashboard(p_start date default current_date, p_end date default current_date)
returns jsonb
language plpgsql security definer set search_path=public
as $$
declare
  c uuid;
  sales numeric := 0;
  cogs numeric := 0;
  expenses numeric := 0;
  tx_count bigint := 0;
  cash_in numeric := 0;
  cash_sales numeric := 0;
  cash_out numeric := 0;
  cash_expected numeric := 0;
  active_jobs bigint := 0;
  customers bigint := 0;
  low_stock bigint := 0;
  net_profit numeric := 0;
  gross_profit numeric := 0;
begin
  if not public.rt_is_admin() then
    raise exception 'ADMIN_ONLY';
  end if;

  c := public.get_my_company_id();
  if c is null then raise exception 'COMPANY_NOT_FOUND'; end if;

  select coalesce(sum(i.total),0), count(*)
    into sales, tx_count
  from public.invoices i
  where i.company_id=c
    and i.status='PAID'
    and coalesce(i.payment_status,'')='PAID'
    and i.voided_at is null
    and i.created_at >= p_start::timestamp
    and i.created_at < (p_end + 1)::timestamp;

  -- Historical COGS comes from stock movement unit_cost, not today's product cost.
  select coalesce(sum(abs(sm.quantity) * coalesce(sm.unit_cost,0)),0)
    into cogs
  from public.stock_movements sm
  where sm.company_id=c
    and sm.movement_type='SALE'
    and sm.created_at >= p_start::timestamp
    and sm.created_at < (p_end + 1)::timestamp;

  select coalesce(sum(e.amount),0)
    into expenses
  from public.expenses e
  where e.company_id=c
    and e.created_at >= p_start::timestamp
    and e.created_at < (p_end + 1)::timestamp;

  select count(*) into active_jobs
  from public.job_cards j
  where j.company_id=c
    and j.status in ('OPEN','IN_PROGRESS','WAITING_PARTS','READY');

  select count(*) into customers
  from public.customers x
  where x.company_id=c;

  select count(*) into low_stock
  from public.products p
  join public.stock_balances b on b.product_id=p.id
  where p.company_id=c and p.active=true and b.quantity <= p.min_stock;

  select coalesce(sum(case when p.payment_method='CASH' then p.amount else 0 end),0)
    into cash_sales
  from public.payments p
  where p.company_id=c
    and p.created_at >= p_start::timestamp
    and p.created_at < (p_end + 1)::timestamp;

  select coalesce(sum(case when cm.movement_type='CASH_OUT' then cm.amount else 0 end),0),
         coalesce(sum(case when cm.movement_type='CASH_IN' then cm.amount else 0 end),0)
    into cash_out, cash_in
  from public.cash_movements cm
  where cm.company_id=c
    and cm.created_at >= p_start::timestamp
    and cm.created_at < (p_end + 1)::timestamp;

  select coalesce(d.expected_amount,0) into cash_expected
  from public.cash_drawers d
  where d.company_id=c and d.drawer_code='MAIN' and d.status='OPEN'
  order by d.opened_at desc nulls last limit 1;

  gross_profit := sales - cogs;
  net_profit := gross_profit - expenses;

  return jsonb_build_object(
    'period_start',p_start,
    'period_end',p_end,
    'sales',round(sales,2),
    'cogs',round(cogs,2),
    'gross_profit',round(gross_profit,2),
    'expenses',round(expenses,2),
    'net_profit',round(net_profit,2),
    'transactions',tx_count,
    'cash_sales',round(cash_sales,2),
    'cash_out',round(cash_out,2),
    'cash_expected',round(cash_expected,2),
    'active_jobs',active_jobs,
    'customers',customers,
    'low_stock',low_stock
  );
end;
$$;

grant execute on function public.rt_admin_dashboard(date,date) to authenticated;

-- Replace broad financial SELECT policies with role-aware policies.
-- POS staff can see their own invoices/payments; only admins see all financial records.
drop policy if exists invoices_select_own_company on public.invoices;
create policy invoices_select_role_scoped on public.invoices
for select to authenticated
using (
  company_id = public.get_my_company_id()
  and (public.rt_is_admin() or staff_id = public.rt_my_staff_id())
);

drop policy if exists payments_select_own_company on public.payments;
create policy payments_select_role_scoped on public.payments
for select to authenticated
using (
  company_id = public.get_my_company_id()
  and (public.rt_is_admin() or staff_id = public.rt_my_staff_id())
);

drop policy if exists expenses_select_own_company on public.expenses;
create policy expenses_select_admin_only on public.expenses
for select to authenticated
using (
  company_id = public.get_my_company_id() and public.rt_is_admin()
);

drop policy if exists stock_movements_select_own_company on public.stock_movements;
create policy stock_movements_select_admin_only on public.stock_movements
for select to authenticated
using (
  company_id = public.get_my_company_id() and public.rt_is_admin()
);

drop policy if exists audit_logs_select_own_company on public.audit_logs;
create policy audit_logs_select_admin_only on public.audit_logs
for select to authenticated
using (
  company_id = public.get_my_company_id() and public.rt_is_admin()
);

drop policy if exists admin_overrides_select_own_company on public.admin_overrides;
create policy admin_overrides_select_admin_only on public.admin_overrides
for select to authenticated
using (
  company_id = public.get_my_company_id() and public.rt_is_admin()
);

-- Harden override inserts as admin-only. POS staff must never be able to create overrides directly.
drop policy if exists admin_overrides_insert_own_company on public.admin_overrides;
create policy admin_overrides_insert_admin_only on public.admin_overrides
for insert to authenticated
with check (company_id = public.get_my_company_id() and public.rt_is_admin());
