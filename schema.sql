-- Run this in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create or replace function public.is_schooltrack_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.admin_users where user_id = auth.uid()); $$;
revoke all on function public.is_schooltrack_admin() from public;
grant execute on function public.is_schooltrack_admin() to authenticated;

create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  quantity integer not null default 0 check (quantity >= 0),
  condition text not null default 'Good',
  location text not null default '',
  responsible text not null default '',
  status text not null default 'Available',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.app_settings (
  id integer primary key check (id = 1),
  categories text[] not null default array['Computer','Computer peripherals','Furniture','Electrical','Other'],
  updated_at timestamptz not null default now()
);
insert into public.app_settings(id) values (1) on conflict (id) do nothing;
create table if not exists public.activity (
  id uuid primary key default gen_random_uuid(),
  action text not null,
  item text not null,
  by_name text not null default 'User',
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;
alter table public.inventory enable row level security;
alter table public.app_settings enable row level security;
alter table public.activity enable row level security;
-- No client-facing policies on admin_users: only the Edge Function service role manages it.
create policy "Signed-in users can view inventory" on public.inventory for select to authenticated using (true);
create policy "Admins can insert inventory" on public.inventory for insert to authenticated with check (public.is_schooltrack_admin());
create policy "Admins can update inventory" on public.inventory for update to authenticated using (public.is_schooltrack_admin()) with check (public.is_schooltrack_admin());
create policy "Admins can delete inventory" on public.inventory for delete to authenticated using (public.is_schooltrack_admin());
create policy "Signed-in users can view settings" on public.app_settings for select to authenticated using (true);
create policy "Admins can manage settings" on public.app_settings for all to authenticated using (public.is_schooltrack_admin()) with check (public.is_schooltrack_admin());
create policy "Signed-in users can view activity" on public.activity for select to authenticated using (true);
create policy "Admins can add activity" on public.activity for insert to authenticated with check (public.is_schooltrack_admin());

-- Enable Realtime for live updates from other devices.
alter publication supabase_realtime add table public.inventory;
alter publication supabase_realtime add table public.app_settings;
alter publication supabase_realtime add table public.activity;

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.inventory to authenticated;
grant select, insert, update, delete on public.app_settings to authenticated;
grant select, insert on public.activity to authenticated;
