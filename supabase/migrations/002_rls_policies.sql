-- Comunexa — Row Level Security
-- Depende de: 001_initial_schema.sql

-- Helpers (SECURITY DEFINER para leer perfil del usuario actual)
create or replace function public.current_profile()
returns public.profiles
language sql
stable
security definer
set search_path = public
as $$
  select * from public.profiles where id = auth.uid();
$$;

create or replace function public.current_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.current_tenant_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select tenant_id from public.profiles where id = auth.uid();
$$;

create or replace function public.is_platform_superadmin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'platform_superadmin'
  );
$$;

create or replace function public.has_building_access(p_building_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and (
        p.role = 'platform_superadmin'
        or (p.role = 'tenant_admin' and p.tenant_id = (select tenant_id from public.buildings where id = p_building_id))
        or (p.role = 'building_admin' and exists (
          select 1 from public.building_admins ba
          where ba.profile_id = p.id and ba.building_id = p_building_id
        ))
        or (p.role = 'resident' and exists (
          select 1 from public.resident_units ru
          join public.units u on u.id = ru.unit_id
          where ru.profile_id = p.id and u.building_id = p_building_id
        ))
      )
  );
$$;

create or replace function public.has_unit_access(p_unit_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.units u
    where u.id = p_unit_id
      and public.has_building_access(u.building_id)
  );
$$;

-- Habilitar RLS en todas las tablas
alter table public.tenants enable row level security;
alter table public.buildings enable row level security;
alter table public.units enable row level security;
alter table public.profiles enable row level security;
alter table public.building_admins enable row level security;
alter table public.resident_units enable row level security;
alter table public.invoices enable row level security;
alter table public.payments enable row level security;
alter table public.pqr enable row level security;
alter table public.news enable row level security;
alter table public.common_areas enable row level security;
alter table public.reservations enable row level security;
alter table public.visits enable row level security;
alter table public.message_threads enable row level security;
alter table public.messages enable row level security;
alter table public.polls enable row level security;
alter table public.poll_options enable row level security;
alter table public.votes enable row level security;
alter table public.notifications_log enable row level security;

-- TENANTS
create policy tenants_select on public.tenants for select using (
  public.is_platform_superadmin()
  or id = public.current_tenant_id()
);

create policy tenants_insert on public.tenants for insert with check (
  public.is_platform_superadmin()
);

create policy tenants_update on public.tenants for update using (
  public.is_platform_superadmin()
  or (id = public.current_tenant_id() and public.current_role() = 'tenant_admin')
);

-- PROFILES
create policy profiles_select on public.profiles for select using (
  public.is_platform_superadmin()
  or id = auth.uid()
  or (tenant_id = public.current_tenant_id() and public.current_role() in ('tenant_admin', 'building_admin'))
);

create policy profiles_update_self on public.profiles for update using (
  id = auth.uid()
);

create policy profiles_update_admin on public.profiles for update using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() = 'tenant_admin')
);

-- BUILDINGS
create policy buildings_select on public.buildings for select using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() = 'tenant_admin')
  or public.has_building_access(id)
);

create policy buildings_write_admin on public.buildings for all using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() = 'tenant_admin')
) with check (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() = 'tenant_admin')
);

-- UNITS
create policy units_select on public.units for select using (
  public.is_platform_superadmin()
  or public.has_building_access(building_id)
);

create policy units_write_admin on public.units for all using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() in ('tenant_admin', 'building_admin'))
) with check (
  tenant_id = public.current_tenant_id()
);

-- BUILDING_ADMINS / RESIDENT_UNITS (solo admins de tenant)
create policy building_admins_all on public.building_admins for all using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() = 'tenant_admin')
) with check (tenant_id = public.current_tenant_id());

create policy resident_units_select on public.resident_units for select using (
  public.is_platform_superadmin()
  or profile_id = auth.uid()
  or (tenant_id = public.current_tenant_id() and public.current_role() in ('tenant_admin', 'building_admin'))
);

create policy resident_units_write on public.resident_units for all using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() in ('tenant_admin', 'building_admin'))
) with check (tenant_id = public.current_tenant_id());

-- Tablas por edificio/unidad (patrón común)
-- NEWS
create policy news_select on public.news for select using (
  public.has_building_access(building_id)
);

create policy news_write on public.news for all using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() in ('tenant_admin', 'building_admin'))
) with check (tenant_id = public.current_tenant_id());

-- COMMON_AREAS + RESERVATIONS
create policy common_areas_select on public.common_areas for select using (
  public.has_building_access(building_id)
);

create policy common_areas_write on public.common_areas for all using (
  tenant_id = public.current_tenant_id()
  and public.current_role() in ('tenant_admin', 'building_admin')
) with check (tenant_id = public.current_tenant_id());

create policy reservations_select on public.reservations for select using (
  public.has_unit_access(unit_id)
);

create policy reservations_insert_resident on public.reservations for insert with check (
  public.has_unit_access(unit_id) and public.current_role() = 'resident'
);

create policy reservations_update_admin on public.reservations for update using (
  tenant_id = public.current_tenant_id()
  and public.current_role() in ('tenant_admin', 'building_admin')
);

-- VISITS
create policy visits_select on public.visits for select using (
  public.has_building_access(building_id)
);

create policy visits_insert on public.visits for insert with check (
  public.has_unit_access(unit_id)
);

create policy visits_update_admin on public.visits for update using (
  tenant_id = public.current_tenant_id()
  and public.current_role() in ('tenant_admin', 'building_admin')
);

-- PQR
create policy pqr_select on public.pqr for select using (
  public.has_unit_access(unit_id)
);

create policy pqr_insert on public.pqr for insert with check (
  public.has_unit_access(unit_id)
);

create policy pqr_update_admin on public.pqr for update using (
  tenant_id = public.current_tenant_id()
  and public.current_role() in ('tenant_admin', 'building_admin')
);

-- INVOICES + PAYMENTS
create policy invoices_select on public.invoices for select using (
  public.has_unit_access(unit_id)
);

create policy invoices_write_admin on public.invoices for all using (
  tenant_id = public.current_tenant_id()
  and public.current_role() in ('tenant_admin', 'building_admin')
) with check (tenant_id = public.current_tenant_id());

create policy payments_select on public.payments for select using (
  exists (
    select 1 from public.invoices i
    where i.id = invoice_id and public.has_unit_access(i.unit_id)
  )
);

-- POLLS + VOTES
create policy polls_select on public.polls for select using (
  public.has_building_access(building_id)
);

create policy polls_write on public.polls for all using (
  tenant_id = public.current_tenant_id()
  and public.current_role() in ('tenant_admin', 'building_admin')
) with check (tenant_id = public.current_tenant_id());

create policy poll_options_select on public.poll_options for select using (
  exists (select 1 from public.polls p where p.id = poll_id and public.has_building_access(p.building_id))
);

create policy votes_select on public.votes for select using (
  public.has_unit_access(unit_id)
);

create policy votes_insert on public.votes for insert with check (
  public.has_unit_access(unit_id) and public.current_role() = 'resident'
);

-- MESSAGES
create policy message_threads_select on public.message_threads for select using (
  building_id is null
  or public.has_building_access(building_id)
);

create policy messages_select on public.messages for select using (
  exists (
    select 1 from public.message_threads t
    where t.id = thread_id
      and (t.building_id is null or public.has_building_access(t.building_id))
  )
);

create policy messages_insert on public.messages for insert with check (
  sender_id = auth.uid()
);

-- NOTIFICATIONS LOG (solo lectura admin)
create policy notifications_log_select on public.notifications_log for select using (
  public.is_platform_superadmin()
  or (tenant_id = public.current_tenant_id() and public.current_role() in ('tenant_admin', 'building_admin'))
);
