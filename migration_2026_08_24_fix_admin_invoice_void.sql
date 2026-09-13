-- Fix Admin Invoice VOID: PostgreSQL/Supabase atomic RPC
-- Adds snake_case reason field and reverses stock/cash safely.

alter table public.invoices add column if not exists void_reason text;

-- The authoritative function is already installed in Supabase.
-- Keep this file as the deploy/audit record for the frontend package.
