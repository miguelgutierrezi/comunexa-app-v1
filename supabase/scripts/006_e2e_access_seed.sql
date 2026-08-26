-- Seed manual E2E — modelo de acceso + Auth local
--
-- NO es migración. Ejecutar después de `supabase db reset`:
--   ./scripts/e2e-local-setup.sh
-- o:
--   docker exec -i supabase_db_comunexa-app-v1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
--     < supabase/scripts/006_e2e_access_seed.sql
--
-- Usuarios (password en todos): ComunexaE2E!1
--   e2e-single@comunexa.local   → 1 membresía (Torres del Parque)
--   e2e-multi@comunexa.local    → 4 membresías (selector)
--   e2e-noaccess@comunexa.local → sin membresías (/no-access)

create extension if not exists pgcrypto with schema extensions;

create or replace function public.e2e_seed_create_user(
  p_id uuid,
  p_email text,
  p_full_name text
) returns void
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
begin
  insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  ) values (
    '00000000-0000-0000-0000-000000000000',
    p_id,
    'authenticated',
    'authenticated',
    p_email,
    extensions.crypt('ComunexaE2E!1', extensions.gen_salt('bf')),
    now(),
    '',
    '',
    '',
    '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', p_full_name),
    now(),
    now()
  )
  on conflict (id) do update
    set email = excluded.email,
        encrypted_password = excluded.encrypted_password,
        raw_user_meta_data = excluded.raw_user_meta_data,
        confirmation_token = '',
        recovery_token = '',
        email_change_token_new = '',
        email_change = '',
        updated_at = now();

  insert into auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) values (
    p_id,
    p_id,
    p_email,
    jsonb_build_object(
      'sub', p_id::text,
      'email', p_email,
      'email_verified', true,
      'phone_verified', false
    ),
    'email',
    now(),
    now(),
    now()
  )
  on conflict (provider_id, provider) do update
    set identity_data = excluded.identity_data,
        updated_at = now();

  insert into public.profiles (id, full_name, role)
  values (p_id, p_full_name, 'resident')
  on conflict (id) do update
    set full_name = excluded.full_name;
end;
$$;

-- Usuarios
select public.e2e_seed_create_user(
  'e2e00000-0000-4000-8000-000000000001',
  'e2e-single@comunexa.local',
  'Carlos E2E Single'
);
select public.e2e_seed_create_user(
  'e2e00000-0000-4000-8000-000000000002',
  'e2e-multi@comunexa.local',
  'María E2E Multi'
);
select public.e2e_seed_create_user(
  'e2e00000-0000-4000-8000-000000000003',
  'e2e-noaccess@comunexa.local',
  'Ana E2E Sin Acceso'
);

-- Organización demo
insert into public.organizations (id, name, slug, active)
values (
  'e2e00000-0000-4000-8000-000000000010',
  'Comunexa E2E Demo',
  'comunexa-e2e-demo',
  true
)
on conflict (id) do update
  set name = excluded.name, active = true;

-- Propiedades (nombres alineados con seeds Flutter)
insert into public.properties (
  id, organization_id, name, property_type, branding_mode, active
) values
  (
    'e2e00000-0000-4000-8000-000000000101',
    'e2e00000-0000-4000-8000-000000000010',
    'Torres del Parque',
    'residential_complex',
    'co_branded',
    true
  ),
  (
    'e2e00000-0000-4000-8000-000000000102',
    'e2e00000-0000-4000-8000-000000000010',
    'Conjunto Residencial Atalia',
    'residential_complex',
    'co_branded',
    true
  ),
  (
    'e2e00000-0000-4000-8000-000000000103',
    'e2e00000-0000-4000-8000-000000000010',
    'Hotel Boutique Serena',
    'hotel',
    'inherit',
    true
  ),
  (
    'e2e00000-0000-4000-8000-000000000104',
    'e2e00000-0000-4000-8000-000000000010',
    'Parque Empresarial Omega',
    'building',
    'co_branded',
    true
  )
on conflict (id) do update
  set name = excluded.name, active = true;

-- Membresías: single → Torres
insert into public.property_memberships (
  id,
  organization_id,
  property_id,
  profile_id,
  role,
  status
) values
  (
    'e2e00000-0000-4000-8000-000000000201',
    'e2e00000-0000-4000-8000-000000000010',
    'e2e00000-0000-4000-8000-000000000101',
    'e2e00000-0000-4000-8000-000000000001',
    'member',
    'active'
  )
on conflict (property_id, profile_id) do update
  set status = 'active', role = excluded.role;

-- Membresías: multi → 4 propiedades
insert into public.property_memberships (
  id,
  organization_id,
  property_id,
  profile_id,
  role,
  permission_preset_id,
  status
) values
  (
    'e2e00000-0000-4000-8000-000000000211',
    'e2e00000-0000-4000-8000-000000000010',
    'e2e00000-0000-4000-8000-000000000101',
    'e2e00000-0000-4000-8000-000000000002',
    'member',
    null,
    'active'
  ),
  (
    'e2e00000-0000-4000-8000-000000000212',
    'e2e00000-0000-4000-8000-000000000010',
    'e2e00000-0000-4000-8000-000000000102',
    'e2e00000-0000-4000-8000-000000000002',
    'property_manager',
    null,
    'active'
  ),
  (
    'e2e00000-0000-4000-8000-000000000213',
    'e2e00000-0000-4000-8000-000000000010',
    'e2e00000-0000-4000-8000-000000000103',
    'e2e00000-0000-4000-8000-000000000002',
    'property_staff',
    (select id from public.permission_presets where code = 'security_guard'),
    'active'
  ),
  (
    'e2e00000-0000-4000-8000-000000000214',
    'e2e00000-0000-4000-8000-000000000010',
    'e2e00000-0000-4000-8000-000000000104',
    'e2e00000-0000-4000-8000-000000000002',
    'member',
    null,
    'active'
  )
on conflict (property_id, profile_id) do update
  set status = 'active',
      role = excluded.role,
      permission_preset_id = excluded.permission_preset_id;

drop function if exists public.e2e_seed_create_user(uuid, text, text);

do $$
begin
  raise notice 'E2E seed OK — users: e2e-single|multi|noaccess @comunexa.local / ComunexaE2E!1';
end $$;
