-- Enable required extension
create extension if not exists pgcrypto;

-- Profiles linked to Supabase Auth users
create table if not exists public.app_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  phone text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Product catalog
create table if not exists public.products (
  id text primary key,
  name text not null,
  price numeric(12,2) not null check (price >= 0),
  image_url text not null default '',
  category text not null check (category in ('drink', 'provision')),
  drink_type text not null default '',
  added_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);

-- Orders
create table if not exists public.orders (
  id text primary key,
  created_by uuid not null references auth.users(id) on delete cascade,
  recipient_name text not null,
  phone text not null,
  address text not null,
  payment_method text not null,
  note text,
  total numeric(12,2) not null check (total >= 0),
  status text not null default 'Pending' check (status in ('Pending', 'Confirmed', 'Delivered')),
  placed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id bigserial primary key,
  order_id text not null references public.orders(id) on delete cascade,
  product_id text,
  name text not null,
  category text not null,
  quantity integer not null check (quantity > 0),
  price numeric(12,2) not null check (price >= 0),
  image_url text not null default ''
);

-- Home/category/banner/contact settings
create table if not exists public.shop_categories (
  id text primary key,
  type text not null check (type in ('drink', 'provision')),
  name text not null,
  emoji text not null,
  color_value integer not null,
  image_data_uri text,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);

create table if not exists public.carousel_banners (
  id bigserial primary key,
  type text not null check (type in ('drink', 'provision')),
  image_data_uri text not null,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);

-- Updated-at helpers
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.app_profiles;
create trigger trg_profiles_updated_at
before update on public.app_profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at
before update on public.products
for each row execute function public.set_updated_at();

drop trigger if exists trg_orders_updated_at on public.orders;
create trigger trg_orders_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

drop trigger if exists trg_app_settings_updated_at on public.app_settings;
create trigger trg_app_settings_updated_at
before update on public.app_settings
for each row execute function public.set_updated_at();

-- Admin helper
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.app_profiles p
    where p.user_id = auth.uid() and p.is_admin = true
  );
$$;

grant execute on function public.is_admin() to anon, authenticated;

-- Create order + items in one call
create or replace function public.create_order_with_items(
  p_order jsonb,
  p_items jsonb
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order_id text;
  v_uid uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'Authentication required';
  end if;

  v_order_id := coalesce(p_order->>'id', 'ORD-' || extract(epoch from now())::bigint::text);

  insert into public.orders (
    id,
    created_by,
    recipient_name,
    phone,
    address,
    payment_method,
    note,
    total,
    status,
    placed_at
  )
  values (
    v_order_id,
    v_uid,
    coalesce(p_order->>'recipient_name', ''),
    coalesce(p_order->>'phone', ''),
    coalesce(p_order->>'address', ''),
    coalesce(p_order->>'payment_method', ''),
    p_order->>'note',
    coalesce((p_order->>'total')::numeric, 0),
    coalesce(p_order->>'status', 'Pending'),
    coalesce((p_order->>'placed_at')::timestamptz, now())
  );

  insert into public.order_items (
    order_id,
    product_id,
    name,
    category,
    quantity,
    price,
    image_url
  )
  select
    v_order_id,
    nullif(item->>'id', ''),
    coalesce(item->>'name', ''),
    coalesce(item->>'category', ''),
    coalesce((item->>'quantity')::integer, 1),
    coalesce((item->>'price')::numeric, 0),
    coalesce(item->>'image_url', '')
  from jsonb_array_elements(coalesce(p_items, '[]'::jsonb)) item;

  return v_order_id;
end;
$$;

grant execute on function public.create_order_with_items(jsonb, jsonb) to authenticated;

-- RLS
alter table public.app_profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.shop_categories enable row level security;
alter table public.carousel_banners enable row level security;
alter table public.app_settings enable row level security;

-- Profiles policies
drop policy if exists profiles_select_own_or_admin on public.app_profiles;
create policy profiles_select_own_or_admin
on public.app_profiles for select
using (user_id = auth.uid() or public.is_admin());

drop policy if exists profiles_insert_own on public.app_profiles;
create policy profiles_insert_own
on public.app_profiles for insert
with check (user_id = auth.uid());

drop policy if exists profiles_update_own_or_admin on public.app_profiles;
create policy profiles_update_own_or_admin
on public.app_profiles for update
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

-- Public read catalog/settings; admin write
drop policy if exists products_public_read on public.products;
create policy products_public_read
on public.products for select
using (true);

drop policy if exists products_admin_write on public.products;
create policy products_admin_write
on public.products for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists shop_categories_public_read on public.shop_categories;
create policy shop_categories_public_read
on public.shop_categories for select
using (true);

drop policy if exists shop_categories_admin_write on public.shop_categories;
create policy shop_categories_admin_write
on public.shop_categories for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists banners_public_read on public.carousel_banners;
create policy banners_public_read
on public.carousel_banners for select
using (true);

drop policy if exists banners_admin_write on public.carousel_banners;
create policy banners_admin_write
on public.carousel_banners for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists app_settings_public_read on public.app_settings;
create policy app_settings_public_read
on public.app_settings for select
using (true);

drop policy if exists app_settings_admin_write on public.app_settings;
create policy app_settings_admin_write
on public.app_settings for all
using (public.is_admin())
with check (public.is_admin());

-- Orders policies
drop policy if exists orders_select_own_or_admin on public.orders;
create policy orders_select_own_or_admin
on public.orders for select
using (created_by = auth.uid() or public.is_admin());

drop policy if exists orders_insert_own on public.orders;
create policy orders_insert_own
on public.orders for insert
with check (created_by = auth.uid());

drop policy if exists orders_admin_update on public.orders;
create policy orders_admin_update
on public.orders for update
using (public.is_admin())
with check (public.is_admin());

drop policy if exists order_items_select_own_or_admin on public.order_items;
create policy order_items_select_own_or_admin
on public.order_items for select
using (
  public.is_admin() or exists (
    select 1 from public.orders o
    where o.id = order_items.order_id and o.created_by = auth.uid()
  )
);

drop policy if exists order_items_insert_own on public.order_items;
create policy order_items_insert_own
on public.order_items for insert
with check (
  exists (
    select 1 from public.orders o
    where o.id = order_items.order_id and o.created_by = auth.uid()
  )
);

drop policy if exists order_items_admin_update_delete on public.order_items;
create policy order_items_admin_update_delete
on public.order_items for all
using (public.is_admin())
with check (public.is_admin());

-- Public buckets for uploaded assets
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('banner-images', 'banner-images', true)
on conflict (id) do nothing;

drop policy if exists product_images_public_read on storage.objects;
create policy product_images_public_read
on storage.objects for select
using (bucket_id = 'product-images');

drop policy if exists banner_images_public_read on storage.objects;
create policy banner_images_public_read
on storage.objects for select
using (bucket_id = 'banner-images');

drop policy if exists product_images_admin_write on storage.objects;
create policy product_images_admin_write
on storage.objects for all
using (bucket_id = 'product-images' and public.is_admin())
with check (bucket_id = 'product-images' and public.is_admin());

drop policy if exists banner_images_admin_write on storage.objects;
create policy banner_images_admin_write
on storage.objects for all
using (bucket_id = 'banner-images' and public.is_admin())
with check (bucket_id = 'banner-images' and public.is_admin());
