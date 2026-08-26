-- Comunexa — integridad org/property/unit + SELECT de membresías más estricto
-- Depende de: 003_access_model.sql, 004_access_model_grants.sql
--
-- 1) FKs compuestas: organization_id de hijas debe coincidir con properties.
-- 2) occupancies.unit_id debe coincidir con units.property_id.
-- 3) Policies SELECT de membresías/occupancies: propia fila o managers/admins
--    (no has_property_access — evita que un residente enumere roles ajenos).

-- ---------------------------------------------------------------------------
-- FKs compuestas
-- ---------------------------------------------------------------------------

-- Soporta FK (property_id, organization_id) → properties
alter table public.properties
  add constraint properties_id_organization_id_key
  unique (id, organization_id);

-- Soporta FK (unit_id, property_id) → units
-- (id ya es único; el par garantiza property_id para la ocupación)
alter table public.units
  add constraint units_id_property_id_key
  unique (id, property_id);

alter table public.property_memberships
  add constraint property_memberships_property_organization_fkey
  foreign key (property_id, organization_id)
  references public.properties (id, organization_id)
  on delete cascade;

alter table public.occupancies
  add constraint occupancies_property_organization_fkey
  foreign key (property_id, organization_id)
  references public.properties (id, organization_id)
  on delete cascade;

alter table public.occupancies
  add constraint occupancies_unit_property_fkey
  foreign key (unit_id, property_id)
  references public.units (id, property_id)
  on delete cascade;

-- ---------------------------------------------------------------------------
-- Helper: ¿puede listar membresías/occupancies ajenas en una propiedad?
-- ---------------------------------------------------------------------------

create or replace function public.can_manage_property_members(p_property_id uuid)
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
      from public.properties p
      where p.id = p_property_id
        and public.is_organization_admin(p.organization_id)
    )
    or public.is_property_manager(p_property_id)
    or public.has_property_permission(p_property_id, 'manage_members');
$$;

comment on function public.can_manage_property_members(uuid) is
  'Org admin, property_manager o permiso manage_members; no basta ser member/residente.';

-- ---------------------------------------------------------------------------
-- Policies SELECT (reemplazo)
-- ---------------------------------------------------------------------------

drop policy if exists organization_memberships_select
  on public.organization_memberships;

create policy organization_memberships_select
  on public.organization_memberships for select
  to authenticated
  using (
    profile_id = auth.uid()
    or public.is_organization_admin(organization_id)
  );

drop policy if exists property_memberships_select
  on public.property_memberships;

create policy property_memberships_select
  on public.property_memberships for select
  to authenticated
  using (
    profile_id = auth.uid()
    or public.can_manage_property_members(property_id)
  );

drop policy if exists property_membership_permissions_select
  on public.property_membership_permissions;

create policy property_membership_permissions_select
  on public.property_membership_permissions for select
  to authenticated
  using (
    exists (
      select 1 from public.property_memberships pm
      where pm.id = membership_id
        and (
          pm.profile_id = auth.uid()
          or public.can_manage_property_members(pm.property_id)
        )
    )
  );

drop policy if exists occupancies_select on public.occupancies;

create policy occupancies_select
  on public.occupancies for select
  to authenticated
  using (
    profile_id = auth.uid()
    or public.can_manage_property_members(property_id)
  );
