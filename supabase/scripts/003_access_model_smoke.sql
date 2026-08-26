-- Smoke checks for 003_access_model (run against local Supabase after db reset/push).
-- Expect: zero rows (all assertions pass).

do $$
begin
  assert to_regclass('public.organizations') is not null;
  assert to_regclass('public.properties') is not null;
  assert to_regclass('public.organization_memberships') is not null;
  assert to_regclass('public.property_memberships') is not null;
  assert to_regclass('public.occupancies') is not null;
  assert to_regclass('public.permissions') is not null;
  assert to_regclass('public.permission_presets') is not null;
  assert to_regclass('public.permission_preset_permissions') is not null;
  assert to_regclass('public.property_membership_permissions') is not null;

  assert exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'is_platform_superadmin'
  );

  assert exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'units'
      and column_name = 'property_id'
  );

  assert (
    select count(*) from public.permission_presets where code = 'security_guard'
  ) = 1;

  assert (
    select count(*)
    from public.permission_preset_permissions ppp
    join public.permission_presets p on p.id = ppp.preset_id
    where p.code = 'security_guard'
  ) = 7;

  raise notice '003_access_model smoke OK';
end $$;
