-- Comunexa — esquema inicial
-- Fuente canónica: supabase/migrations/001_initial_schema.sql
-- Copia de referencia en docs/database/schema.sql

-- Extensiones
create extension if not exists "pgcrypto";

-- Enums
create type public.user_role as enum (
  'platform_superadmin',
  'tenant_admin',
  'building_admin',
  'resident'
);

create type public.invoice_status as enum (
  'draft',
  'pending',
  'paid',
  'overdue',
  'cancelled'
);

create type public.payment_status as enum (
  'pending',
  'approved',
  'declined',
  'refunded'
);

create type public.pqr_status as enum (
  'open',
  'in_progress',
  'resolved',
  'closed'
);

create type public.reservation_status as enum (
  'pending',
  'confirmed',
  'cancelled',
  'completed'
);

create type public.resident_unit_role as enum (
  'owner',
  'tenant'
);

-- Tenants (administradoras)
create table public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  slogan text,
  logo_url text,
  primary_color text,
  secondary_color text,
  contact_address text,
  contact_phone text,
  contact_email text,
  plan text default 'standard',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Edificios / conjuntos
create table public.buildings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  address text,
  city text,
  country text not null default 'CO',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_buildings_tenant_id on public.buildings(tenant_id);

-- Unidades (apartamentos, locales, etc.)
create table public.units (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  building_id uuid not null references public.buildings(id) on delete cascade,
  identifier text not null,
  unit_type text,
  area_m2 numeric(10, 2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (building_id, identifier)
);

create index idx_units_tenant_id on public.units(tenant_id);
create index idx_units_building_id on public.units(building_id);

-- Perfiles (extiende auth.users)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid references public.tenants(id) on delete set null,
  role public.user_role not null default 'resident',
  full_name text not null,
  phone text,
  avatar_url text,
  fcm_token text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_profiles_tenant_id on public.profiles(tenant_id);
create index idx_profiles_role on public.profiles(role);

-- Admin de edificio ↔ edificios
create table public.building_admins (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  building_id uuid not null references public.buildings(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (profile_id, building_id)
);

create index idx_building_admins_tenant_id on public.building_admins(tenant_id);
create index idx_building_admins_profile_id on public.building_admins(profile_id);

-- Residente ↔ unidad
create table public.resident_units (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  resident_role public.resident_unit_role not null default 'owner',
  is_primary boolean not null default true,
  created_at timestamptz not null default now(),
  unique (profile_id, unit_id)
);

create index idx_resident_units_tenant_id on public.resident_units(tenant_id);
create index idx_resident_units_profile_id on public.resident_units(profile_id);
create index idx_resident_units_unit_id on public.resident_units(unit_id);

-- Facturación
create table public.invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  period text not null,
  amount numeric(12, 2) not null,
  currency text not null default 'COP',
  status public.invoice_status not null default 'pending',
  due_date date not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_invoices_tenant_id on public.invoices(tenant_id);
create index idx_invoices_unit_id on public.invoices(unit_id);
create index idx_invoices_status on public.invoices(status);

-- Pagos
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  amount numeric(12, 2) not null,
  payment_method text,
  gateway_reference text,
  status public.payment_status not null default 'pending',
  paid_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_payments_tenant_id on public.payments(tenant_id);
create index idx_payments_invoice_id on public.payments(invoice_id);

-- PQR
create table public.pqr (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  category text not null,
  description text not null,
  status public.pqr_status not null default 'open',
  assigned_to uuid references public.profiles(id) on delete set null,
  attachment_urls text[] default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_pqr_tenant_id on public.pqr(tenant_id);
create index idx_pqr_unit_id on public.pqr(unit_id);
create index idx_pqr_status on public.pqr(status);

-- Noticias / cartelera
create table public.news (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  building_id uuid not null references public.buildings(id) on delete cascade,
  title text not null,
  body text not null,
  author_id uuid references public.profiles(id) on delete set null,
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_news_tenant_id on public.news(tenant_id);
create index idx_news_building_id on public.news(building_id);

-- Zonas comunes
create table public.common_areas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  building_id uuid not null references public.buildings(id) on delete cascade,
  name text not null,
  capacity int,
  rules text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_common_areas_tenant_id on public.common_areas(tenant_id);
create index idx_common_areas_building_id on public.common_areas(building_id);

-- Reservas
create table public.reservations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  common_area_id uuid not null references public.common_areas(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  reserved_date date not null,
  start_time time not null,
  end_time time not null,
  status public.reservation_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_reservations_tenant_id on public.reservations(tenant_id);
create index idx_reservations_common_area_id on public.reservations(common_area_id);
create index idx_reservations_date on public.reservations(reserved_date);

-- Visitas
create table public.visits (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  building_id uuid not null references public.buildings(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  visitor_name text not null,
  visitor_document text,
  entry_at timestamptz not null default now(),
  exit_at timestamptz,
  authorized_by uuid references public.profiles(id) on delete set null,
  report_pdf_url text,
  created_at timestamptz not null default now()
);

create index idx_visits_tenant_id on public.visits(tenant_id);
create index idx_visits_building_id on public.visits(building_id);
create index idx_visits_unit_id on public.visits(unit_id);

-- Mensajería (hilos simplificados)
create table public.message_threads (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  building_id uuid references public.buildings(id) on delete cascade,
  subject text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  thread_id uuid not null references public.message_threads(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create index idx_messages_tenant_id on public.messages(tenant_id);
create index idx_messages_thread_id on public.messages(thread_id);

-- Votaciones
create table public.polls (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  building_id uuid not null references public.buildings(id) on delete cascade,
  title text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table public.poll_options (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  poll_id uuid not null references public.polls(id) on delete cascade,
  label text not null,
  sort_order int not null default 0
);

create table public.votes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  poll_id uuid not null references public.polls(id) on delete cascade,
  poll_option_id uuid not null references public.poll_options(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  voted_at timestamptz not null default now(),
  unique (poll_id, unit_id)
);

create index idx_polls_tenant_id on public.polls(tenant_id);
create index idx_polls_building_id on public.polls(building_id);

-- Log de notificaciones push
create table public.notifications_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  building_id uuid references public.buildings(id) on delete set null,
  title text not null,
  body text not null,
  payload jsonb default '{}',
  sent_at timestamptz not null default now()
);

create index idx_notifications_log_tenant_id on public.notifications_log(tenant_id);

-- Trigger updated_at genérico
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger tenants_updated_at before update on public.tenants
  for each row execute function public.set_updated_at();
create trigger buildings_updated_at before update on public.buildings
  for each row execute function public.set_updated_at();
create trigger units_updated_at before update on public.units
  for each row execute function public.set_updated_at();
create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();
create trigger invoices_updated_at before update on public.invoices
  for each row execute function public.set_updated_at();
create trigger pqr_updated_at before update on public.pqr
  for each row execute function public.set_updated_at();
create trigger news_updated_at before update on public.news
  for each row execute function public.set_updated_at();
create trigger common_areas_updated_at before update on public.common_areas
  for each row execute function public.set_updated_at();
create trigger reservations_updated_at before update on public.reservations
  for each row execute function public.set_updated_at();

-- Perfil automático al registrarse (ajustar según flujo de invitación)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
