-- REV TORQ v0.9.0 — staff receipt history / reprint RPCs
-- Additive only. Does not widen invoice/payment RLS and does not change sale/stock/payment records.

create or replace function public.rt_staff_receipt_history(
  p_search text default null,
  p_limit integer default 20,
  p_offset integer default 0
)
returns table(
  id uuid,
  invoice_no text,
  total numeric,
  status text,
  payment_status text,
  created_at timestamptz,
  customer_name text,
  customer_phone text,
  vehicle_plate text,
  payment_method text,
  amount_paid numeric,
  staff_name text,
  staff_code text
)
language plpgsql
security definer
set search_path=public
as $$
declare
  ctx record;
  q text := lower(trim(coalesce(p_search,'')));
  lim integer := least(greatest(coalesce(p_limit,20),1),50);
  offv integer := greatest(coalesce(p_offset,0),0);
begin
  select * into ctx from public.rt_staff_context() limit 1;
  if ctx.staff_id is null or lower(coalesce(ctx.role,'')) not in
    ('owner','admin','administrator','super_admin','superadmin','manager','staff','pos','cashier') then
    raise exception 'REPRINT_ROLE_NOT_ALLOWED';
  end if;

  return query
  select
    i.id,
    i.invoice_no,
    i.total,
    i.status,
    i.payment_status,
    i.created_at,
    coalesce(c.name,'Walk-in')::text as customer_name,
    coalesce(c.phone,'')::text as customer_phone,
    coalesce(v.plate_no,'')::text as vehicle_plate,
    coalesce(pay.payment_method,'-')::text as payment_method,
    coalesce(pay.amount_paid,i.total,0)::numeric as amount_paid,
    coalesce(s.name,s.staff_code,'-')::text as staff_name,
    coalesce(s.staff_code,'-')::text as staff_code
  from public.invoices i
  left join public.customers c on c.id=i.customer_id and c.company_id=i.company_id
  left join public.vehicles v on v.id=i.vehicle_id and v.company_id=i.company_id
  left join public.staff s on s.id=i.staff_id and s.company_id=i.company_id
  left join lateral (
    select
      string_agg(distinct p.payment_method, ' + ' order by p.payment_method) as payment_method,
      sum(p.amount) as amount_paid
    from public.payments p
    where p.invoice_id=i.id and p.company_id=i.company_id
  ) pay on true
  where i.company_id=ctx.company_id
    and (
      q='' or
      lower(coalesce(i.invoice_no,'')) like '%'||q||'%' or
      lower(coalesce(c.name,'')) like '%'||q||'%' or
      lower(coalesce(c.phone,'')) like '%'||q||'%' or
      lower(coalesce(v.plate_no,'')) like '%'||q||'%'
    )
  order by i.created_at desc
  limit lim offset offv;
end;
$$;

revoke all on function public.rt_staff_receipt_history(text,integer,integer) from public;
grant execute on function public.rt_staff_receipt_history(text,integer,integer) to authenticated;

create or replace function public.rt_staff_receipt_detail(p_invoice_id uuid)
returns jsonb
language plpgsql
security definer
set search_path=public
as $$
declare
  ctx record;
  out_json jsonb;
begin
  select * into ctx from public.rt_staff_context() limit 1;
  if ctx.staff_id is null or lower(coalesce(ctx.role,'')) not in
    ('owner','admin','administrator','super_admin','superadmin','manager','staff','pos','cashier') then
    raise exception 'REPRINT_ROLE_NOT_ALLOWED';
  end if;

  select jsonb_build_object(
    'id', i.id,
    'invoiceNo', i.invoice_no,
    'customerId', i.customer_id,
    'vehicleId', i.vehicle_id,
    'subtotal', coalesce(i.subtotal,0),
    'discount', coalesce(i.discount,0),
    'tax', coalesce(i.tax,0),
    'total', coalesce(i.total,0),
    'status', i.status,
    'paymentStatus', i.payment_status,
    'createdAt', i.created_at,
    'customerName', coalesce(c.name,'Walk-in'),
    'customerPhone', coalesce(c.phone,''),
    'plateNo', coalesce(v.plate_no,''),
    'vehicleModel', trim(concat_ws(' ',v.brand,v.model,v.variant)),
    'createdBy', coalesce(s.staff_code,s.name,'-'),
    'staffName', coalesce(s.name,s.staff_code,'-'),
    'paymentMethod', coalesce(pay.payment_method, checkout.metadata->>'payment_method', 'CASH'),
    'amountPaid', coalesce(
      case when nullif(checkout.metadata->>'amount_received','') is not null then (checkout.metadata->>'amount_received')::numeric end,
      pay.amount_paid,
      i.total,
      0
    ),
    'change', coalesce(
      case when nullif(checkout.metadata->>'change','') is not null then (checkout.metadata->>'change')::numeric end,
      0
    ),
    'items', coalesce(items.data,'[]'::jsonb)
  ) into out_json
  from public.invoices i
  left join public.customers c on c.id=i.customer_id and c.company_id=i.company_id
  left join public.vehicles v on v.id=i.vehicle_id and v.company_id=i.company_id
  left join public.staff s on s.id=i.staff_id and s.company_id=i.company_id
  left join lateral (
    select
      string_agg(distinct p.payment_method, ' + ' order by p.payment_method) as payment_method,
      sum(p.amount) as amount_paid
    from public.payments p
    where p.invoice_id=i.id and p.company_id=i.company_id
  ) pay on true
  left join lateral (
    select al.metadata
    from public.audit_logs al
    where al.company_id=i.company_id
      and al.entity_id=i.id
      and al.action='POS_CHECKOUT'
    order by al.created_at desc
    limit 1
  ) checkout on true
  left join lateral (
    select jsonb_agg(
      jsonb_build_object(
        'name', coalesce(nullif(ii.description,''), prod.name, prod.sku, 'Item'),
        'sku', coalesce(prod.sku,''),
        'qty', coalesce(ii.quantity,0),
        'quantity', coalesce(ii.quantity,0),
        'price', coalesce(ii.unit_price,0),
        'unitPrice', coalesce(ii.unit_price,0),
        'lineTotal', coalesce(ii.line_total,0),
        'itemType', coalesce(ii.job_item_type,'PART')
      ) order by ii.id
    ) as data
    from public.invoice_items ii
    left join public.products prod on prod.id=ii.product_id
    where ii.invoice_id=i.id
  ) items on true
  where i.id=p_invoice_id and i.company_id=ctx.company_id
  limit 1;

  if out_json is null then raise exception 'INVOICE_NOT_FOUND'; end if;
  return out_json;
end;
$$;

revoke all on function public.rt_staff_receipt_detail(uuid) from public;
grant execute on function public.rt_staff_receipt_detail(uuid) to authenticated;

create or replace function public.rt_log_receipt_reprint(
  p_invoice_id uuid,
  p_source text default 'POS'
)
returns jsonb
language plpgsql
security definer
set search_path=public
as $$
declare
  ctx record;
  inv record;
  cnt integer;
begin
  select * into ctx from public.rt_staff_context() limit 1;
  if ctx.staff_id is null or lower(coalesce(ctx.role,'')) not in
    ('owner','admin','administrator','super_admin','superadmin','manager','staff','pos','cashier') then
    raise exception 'REPRINT_ROLE_NOT_ALLOWED';
  end if;

  select id,company_id,location_id,transaction_id,invoice_no
  into inv
  from public.invoices
  where id=p_invoice_id and company_id=ctx.company_id
  limit 1;
  if inv.id is null then raise exception 'INVOICE_NOT_FOUND'; end if;

  select count(*)::integer + 1 into cnt
  from public.audit_logs
  where company_id=ctx.company_id and entity_id=inv.id and action='RECEIPT_REPRINT';

  insert into public.audit_logs(
    company_id,location_id,transaction_id,staff_id,action,entity_type,entity_id,metadata
  ) values (
    ctx.company_id,coalesce(inv.location_id,ctx.location_id),inv.transaction_id,ctx.staff_id,
    'RECEIPT_REPRINT','INVOICE',inv.id,
    jsonb_build_object(
      'invoice_no',inv.invoice_no,
      'source',coalesce(nullif(trim(p_source),''),'POS'),
      'reprint_count',cnt,
      'reprinted_at',now()
    )
  );

  return jsonb_build_object('success',true,'invoice_id',inv.id,'invoice_no',inv.invoice_no,'reprint_count',cnt);
end;
$$;

revoke all on function public.rt_log_receipt_reprint(uuid,text) from public;
grant execute on function public.rt_log_receipt_reprint(uuid,text) to authenticated;
