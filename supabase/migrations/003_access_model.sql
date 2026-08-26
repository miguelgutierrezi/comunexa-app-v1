-- Comunexa — modelo objetivo mínimo de identidad y acceso
-- Depende de: 001_initial_schema.sql, 002_rls_policies.sql
--
-- Crea organizations / properties / memberships / occupancies / permisos.
-- No elimina tenants / buildings / building_admins / resident_units (cutover posterior).
-- profiles.role (user_role) queda legacy; el privilegio global pasa a is_platform_superadmin.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type public.organization_membership_role as enum (
  'organization_admin',
  'member'
);

create type public.property_membership_role as enum (
  'property_manager',
  'property_staff',
  'member'
);

create type public.membership_status as enum (
  'active',
  'invited',
  'suspended',
  'ended'
);

create type public.property_type as enum (
  'building',
  'residential_complex',
  'hotel' -- reservado; no alcance MVP PH
);

create type public.branding_mode as enum (
  'inherit',
  'co_branded',
  'white_label' -- enterprise futuro
);

create type public.occupancy_type as enum (
  'owner',
  'tenant',
  'authorized_resident',
  'representative'
);

create type public.occupancy_status as enum (
  'active',
  'ended',
  'suspended'
);

-- ---------------------------------------------------------------------------
-- organizations
-- ---------------------------------------------------------------------------

create table public.organizations (
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

create trigger organizations_updated_at before update on public.organizations
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- properties
-- ---------------------------------------------------------------------------

create table public.properties (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null,
  display_name text,
  property_type public.property_type not null default 'building',
  address text,
  city text,
  country text not null default 'CO',
  logo_url text,
  cover_image_url text,
  primary_color text,
  secondary_color text,
  branding_mode public.branding_mode not null default 'co_branded',
  contact_phone text,
  contact_email text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_properties_organization_id on public.properties(organization_id);

create trigger properties_updated_at before update on public.properties
  for each row execute function public.set_updated_at();

-- Puente opcional hacia el modelo legacy (buildings/units) hasta el cutover.
alter table public.units
  add column property_id uuid references public.properties(id) on delete set null;

create index idx_units_property_id on public.units(property_id);

-- ---------------------------------------------------------------------------
-- profiles: privilegio de plataforma separado del rol operativo legacy
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column is_platform_superadmin boolean not null default false;

update public.profiles
set is_platform_superadmin = true
where role = 'platform_superadmin';

comment on column public.profiles.role is
  'Legacy (001). Acceso operativo vive en organization_memberships / property_memberships.';
comment on column public.profiles.is_platform_superadmin is
  'Privilegio global Comunexa; no implica admin de organización/propiedad.';
comment on column public.profiles.tenant_id is
  'Legacy (001). Preferir memberships por organization_id / property_id.';

-- ---------------------------------------------------------------------------
-- Catálogo de permisos y presets
-- ---------------------------------------------------------------------------

create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  description text,
  created_at timestamptz not null default now()
);

create table public.permission_presets (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  created_at timestamptz not null default now()
);

create table public.permission_preset_permissions (
  preset_id uuid not null references public.permission_presets(id) on delete cascade,
  permission_id uuid not null references public.permissions(id) on delete cascade,
  primary key (preset_id, permission_id)
);

-- Seed mínimo: preset security_guard (property_staff)
insert into public.permissions (code, description) values
  ('view_expected_visits', 'Ver visitas esperadas'),
  ('register_visit_entry', 'Registrar entrada de visita'),
  ('register_visit_exit', 'Registrar salida de visita'),
  ('register_vehicle_entry', 'Registrar entrada de vehículo'),
  ('register_vehicle_exit', 'Registrar salida de vehículo'),
  ('verify_resident_authorization', 'Verificar autorización de residente'),
  ('view_access_history_limited', 'Ver historial de acceso limitado'),
  ('manage_members', 'Invitar/aprobar miembros en la propiedad');

insert into public.permission_presets (code, name, description) values
  (
    'security_guard',
    'Vigilancia',
    'Preset limitado de property_staff para control de acceso'
  );

insert into public.permission_preset_permissions (preset_id, permission_id)
select p.id, perm.id
from public.permission_presets p
cross join public.permissions perm
where p.code = 'security_guard'
  and perm.code in (
    'view_expected_visits',
    'register_visit_entry',
    'register_visit_exit',
    'register_vehicle_entry',
    'register_vehicle_exit',
    'verify_resident_authorization',
    'view_access_history_limited'
  );

-- ---------------------------------------------------------------------------
-- Memberships
-- ---------------------------------------------------------------------------

create table public.organization_memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role public.organization_membership_role not null,
  status public.membership_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, profile_id)
);

create index idx_organization_memberships_organization_id
  on public.organization_memberships(organization_id);
create index idx_organization_memberships_profile_id
  on public.organization_memberships(profile_id);

create trigger organization_memberships_updated_at
  before update on public.organization_memberships
  for each row execute function public.set_updated_at();

create table public.property_memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role public.property_membership_role not null,
  permission_preset_id uuid references public.permission_presets(id) on delete set null,
  status public.membership_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (property_id, profile_id)
);

create index idx_property_memberships_organization_id
  on public.property_memberships(organization_id);
create index idx_property_memberships_property_id
  on public.property_memberships(property_id);
create index idx_property_memberships_profile_id
  on public.property_memberships(profile_id);
create index idx_property_memberships_preset_id
  on public.property_memberships(permission_preset_id);

create trigger property_memberships_updated_at
  before update on public.property_memberships
  for each row execute function public.set_updated_at();

-- Permisos explícitos por membresía (además o en lugar del preset)
create table public.property_membership_permissions (
  membership_id uuid not null
    references public.property_memberships(id) on delete cascade,
  permission_id uuid not null
    references public.permissions(id) on delete cascade,
  primary key (membership_id, permission_id)
);

-- ---------------------------------------------------------------------------
-- Occupancies (vínculo perfil ↔ unidad con vigencia)
-- ---------------------------------------------------------------------------

create table public.occupancies (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  occupancy_type public.occupancy_type not null default 'owner',
  status public.occupancy_status not null default 'active',
  valid_from date not null default (current_date),
  valid_until date,
  is_primary boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint occupancies_valid_range_chk check (
    valid_until is null or valid_until >= valid_from
  )
);

create unique index uq_occupancies_active_profile_unit
  on public.occupancies (profile_id, unit_id)
  where status = 'active';

create index idx_occupancies_organization_id on public.occupancies(organization_id);
create index idx_occupancies_property_id on public.occupancies(property_id);
create index idx_occupancies_unit_id on public.occupancies(unit_id);
create index idx_occupancies_profile_id on public.occupancies(profile_id);

create trigger occupancies_updated_at before update on public.occupancies
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Helpers RLS (modelo objetivo)
-- ---------------------------------------------------------------------------

create or replace function public.is_platform_superadmin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and (
        is_platform_superadmin = true
        or role = 'platform_superadmin' -- compat legacy 001/002
      )
  );
$$;

create or replace function public.has_organization_access(p_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_platform_superadmin()
    or exists (
      select 1 from public.organization_memberships om
      where om.profile_id = auth.uid()
        and om.organization_id = p_organization_id
        and om.status = 'active'
    )
    or exists (
      select 1 from public.property_memberships pm
      where pm.profile_id = auth.uid()
        and pm.organization_id = p_organization_id
        and pm.status = 'active'
    );
$$;

create or replace function public.has_property_access(p_property_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_platform_superadmin()
    or exists (
      select 1 from public.property_memberships pm
      where pm.profile_id = auth.uid()
        and pm.property_id = p_property_id
        and pm.status = 'active'
    )
    or exists (
      select 1
      from public.organization_memberships om
      join public.properties p on p.organization_id = om.organization_id
      where om.profile_id = auth.uid()
        and om.role = 'organization_admin'
        and om.status = 'active'
        and p.id = p_property_id
    )
    or exists (
      select 1 from public.occupancies o
      where o.profile_id = auth.uid()
        and o.property_id = p_property_id
        and o.status = 'active'
    );
$$;

create or replace function public.has_property_permission(
  p_property_id uuid,
  p_permission_code text
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_platform_superadmin()
    or exists (
      select 1
      from public.organization_memberships om
      join public.properties p on p.organization_id = om.organization_id
      where om.profile_id = auth.uid()
        and om.role = 'organization_admin'
        and om.status = 'active'
        and p.id = p_property_id
    )
    or exists (
      select 1 from public.property_memberships pm
      where pm.profile_id = auth.uid()
        and pm.property_id = p_property_id
        and pm.status = 'active'
        and pm.role = 'property_manager'
    )
    or exists (
      select 1
      from public.property_memberships pm
      join public.permission_preset_permissions ppp
        on ppp.preset_id = pm.permission_preset_id
      join public.permissions perm on perm.id = ppp.permission_id
      where pm.profile_id = auth.uid()
        and pm.property_id = p_property_id
        and pm.status = 'active'
        and perm.code = p_permission_code
    )
    or exists (
      select 1
      from public.property_memberships pm
      join public.property_membership_permissions pmp
        on pmp.membership_id = pm.id
      join public.permissions perm on perm.id = pmp.permission_id
      where pm.profile_id = auth.uid()
        and pm.property_id = p_property_id
        and pm.status = 'active'
        and perm.code = p_permission_code
    );
$$;

create or replace function public.is_organization_admin(p_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_platform_superadmin()
    or exists (
      select 1 from public.organization_memberships om
      where om.profile_id = auth.uid()
        and om.organization_id = p_organization_id
        and om.role = 'organization_admin'
        and om.status = 'active'
    );
$$;

create or replace function public.is_property_manager(p_property_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_platform_superadmin()
    or exists (
      select 1 from public.property_memberships pm
      where pm.profile_id = auth.uid()
        and pm.property_id = p_property_id
        and pm.role = 'property_manager'
        and pm.status = 'active'
    );
$$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.organizations enable row level security;
alter table public.properties enable row level security;
alter table public.organization_memberships enable row level security;
alter table public.property_memberships enable row level security;
alter table public.property_membership_permissions enable row level security;
alter table public.occupancies enable row level security;
alter table public.permissions enable row level security;
alter table public.permission_presets enable row level security;
alter table public.permission_preset_permissions enable row level security;

-- Catálogo: lectura autenticada
create policy permissions_select_authenticated
  on public.permissions for select
  to authenticated
  using (true);

create policy permission_presets_select_authenticated
  on public.permission_presets for select
  to authenticated
  using (true);

create policy permission_preset_permissions_select_authenticated
  on public.permission_preset_permissions for select
  to authenticated
  using (true);

-- organizations
create policy organizations_select
  on public.organizations for select
  to authenticated
  using (public.has_organization_access(id));

create policy organizations_insert_superadmin
  on public.organizations for insert
  to authenticated
  with check (public.is_platform_superadmin());

create policy organizations_update
  on public.organizations for update
  to authenticated
  using (public.is_organization_admin(id));

create policy organizations_delete_superadmin
  on public.organizations for delete
  to authenticated
  using (public.is_platform_superadmin());

-- properties
create policy properties_select
  on public.properties for select
  to authenticated
  using (public.has_property_access(id));

create policy properties_insert
  on public.properties for insert
  to authenticated
  with check (public.is_organization_admin(organization_id));

create policy properties_update
  on public.properties for update
  to authenticated
  using (
    public.is_organization_admin(organization_id)
    or public.is_property_manager(id)
  );

create policy properties_delete
  on public.properties for delete
  to authenticated
  using (public.is_organization_admin(organization_id));

-- organization_memberships
create policy organization_memberships_select
  on public.organization_memberships for select
  to authenticated
  using (
    profile_id = auth.uid()
    or public.has_organization_access(organization_id)
  );

create policy organization_memberships_insert
  on public.organization_memberships for insert
  to authenticated
  with check (public.is_organization_admin(organization_id));

create policy organization_memberships_update
  on public.organization_memberships for update
  to authenticated
  using (public.is_organization_admin(organization_id));

create policy organization_memberships_delete
  on public.organization_memberships for delete
  to authenticated
  using (public.is_organization_admin(organization_id));

-- property_memberships
create policy property_memberships_select
  on public.property_memberships for select
  to authenticated
  using (
    profile_id = auth.uid()
    or public.has_property_access(property_id)
  );

create policy property_memberships_insert
  on public.property_memberships for insert
  to authenticated
  with check (
    public.is_organization_admin(organization_id)
    or public.is_property_manager(property_id)
    or public.has_property_permission(property_id, 'manage_members')
  );

create policy property_memberships_update
  on public.property_memberships for update
  to authenticated
  using (
    public.is_organization_admin(organization_id)
    or public.is_property_manager(property_id)
    or public.has_property_permission(property_id, 'manage_members')
  );

create policy property_memberships_delete
  on public.property_memberships for delete
  to authenticated
  using (
    public.is_organization_admin(organization_id)
    or public.is_property_manager(property_id)
  );

-- property_membership_permissions
create policy property_membership_permissions_select
  on public.property_membership_permissions for select
  to authenticated
  using (
    exists (
      select 1 from public.property_memberships pm
      where pm.id = membership_id
        and (
          pm.profile_id = auth.uid()
          or public.has_property_access(pm.property_id)
        )
    )
  );

create policy property_membership_permissions_insert
  on public.property_membership_permissions for insert
  to authenticated
  with check (
    exists (
      select 1 from public.property_memberships pm
      where pm.id = membership_id
        and (
          public.is_organization_admin(pm.organization_id)
          or public.is_property_manager(pm.property_id)
        )
    )
  );

create policy property_membership_permissions_update
  on public.property_membership_permissions for update
  to authenticated
  using (
    exists (
      select 1 from public.property_memberships pm
      where pm.id = membership_id
        and (
          public.is_organization_admin(pm.organization_id)
          or public.is_property_manager(pm.property_id)
        )
    )
  );

create policy property_membership_permissions_delete
  on public.property_membership_permissions for delete
  to authenticated
  using (
    exists (
      select 1 from public.property_memberships pm
      where pm.id = membership_id
        and (
          public.is_organization_admin(pm.organization_id)
          or public.is_property_manager(pm.property_id)
        )
    )
  );

-- occupancies
create policy occupancies_select
  on public.occupancies for select
  to authenticated
  using (
    profile_id = auth.uid()
    or public.has_property_access(property_id)
  );

create policy occupancies_insert
  on public.occupancies for insert
  to authenticated
  with check (
    public.is_organization_admin(organization_id)
    or public.is_property_manager(property_id)
    or public.has_property_permission(property_id, 'manage_members')
  );

create policy occupancies_update
  on public.occupancies for update
  to authenticated
  using (
    public.is_organization_admin(organization_id)
    or public.is_property_manager(property_id)
    or public.has_property_permission(property_id, 'manage_members')
  );

create policy occupancies_delete
  on public.occupancies for delete
  to authenticated
  using (public.is_organization_admin(organization_id));

