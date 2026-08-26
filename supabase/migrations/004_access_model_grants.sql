-- Comunexa — grants para el modelo de acceso 003
-- PostgREST / rol `authenticated` necesitan privilegios de tabla;
-- RLS decide qué filas son visibles.

grant select, insert, update, delete on
  public.organizations,
  public.properties,
  public.organization_memberships,
  public.property_memberships,
  public.property_membership_permissions,
  public.occupancies
to authenticated;

grant select on
  public.permissions,
  public.permission_presets,
  public.permission_preset_permissions
to authenticated;

-- Lectura de units para ocupaciones (escritura sigue en legacy/admins).
grant select on public.units to authenticated;
