-- pgTAP: integridad FK + SELECT estricto de membresías (005)
-- Escenarios:
-- 1) residente no enumera membresías ajenas
-- 2) manager lista membresías de su propiedad
-- 3) FK compuesta rechaza organization_id inconsistente
-- 4) FK compuesta rechaza unit/property inconsistente
--
-- Ejecutar: supabase start && supabase test db

begin;

create extension if not exists pgtap with schema extensions;

select plan(6);

create schema if not exists tests;

create or replace function tests.create_user(p_id uuid, p_email text)
returns void
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
    crypt('test-password', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', p_email),
    now(),
    now()
  )
  on conflict (id) do nothing;

  insert into public.profiles (id, full_name, role)
  values (p_id, p_email, 'resident')
  on conflict (id) do update
    set full_name = excluded.full_name;
end;
$$;

create or replace function tests.authenticate_as(p_user_id uuid)
returns void
language plpgsql
set search_path = public
as $$
begin
  perform set_config('request.jwt.claim.sub', p_user_id::text, true);
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config(
    'request.jwt.claims',
    json_build_object(
      'sub', p_user_id::text,
      'role', 'authenticated'
    )::text,
    true
  );
  execute 'set local role authenticated';
end;
$$;

create or replace function tests.clear_authentication()
returns void
language plpgsql
set search_path = public
as $$
begin
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claim.role', '', true);
  perform set_config('request.jwt.claims', '', true);
  execute 'reset role';
end;
$$;

grant usage on schema tests to postgres, anon, authenticated, service_role;
grant execute on all functions in schema tests to postgres, anon, authenticated, service_role;

select tests.clear_authentication();

select tests.create_user(
  'c1000000-0000-4000-8000-000000000101',
  'mgr005@test.comunexa.local'
);
select tests.create_user(
  'c1000000-0000-4000-8000-000000000102',
  'res005@test.comunexa.local'
);
select tests.create_user(
  'c1000000-0000-4000-8000-000000000103',
  'other005@test.comunexa.local'
);
select tests.create_user(
  'c1000000-0000-4000-8000-000000000104',
  'fk005@test.comunexa.local'
);

insert into public.organizations (id, name, slug)
values
  ('a1000000-0000-4000-8000-000000000001', 'Org 005 Alpha', 'org-005-alpha'),
  ('a1000000-0000-4000-8000-000000000002', 'Org 005 Beta', 'org-005-beta')
on conflict (id) do nothing;

insert into public.properties (
  id, organization_id, name, property_type, branding_mode
) values
  (
    'b1000000-0000-4000-8000-000000000011',
    'a1000000-0000-4000-8000-000000000001',
    'Prop 005 A1',
    'building',
    'co_branded'
  ),
  (
    'b1000000-0000-4000-8000-000000000021',
    'a1000000-0000-4000-8000-000000000002',
    'Prop 005 B1',
    'building',
    'co_branded'
  )
on conflict (id) do nothing;

insert into public.tenants (id, name, slug)
values (
  'd1000000-0000-4000-8000-000000000001',
  'Legacy 005',
  'legacy-005'
)
on conflict (id) do nothing;

insert into public.buildings (id, tenant_id, name)
values (
  'e1000000-0000-4000-8000-000000000001',
  'd1000000-0000-4000-8000-000000000001',
  'Legacy Building 005'
)
on conflict (id) do nothing;

insert into public.units (
  id, tenant_id, building_id, identifier, property_id
) values (
  'f1000000-0000-4000-8000-000000000001',
  'd1000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  '201',
  'b1000000-0000-4000-8000-000000000011'
)
on conflict (id) do nothing;

insert into public.property_memberships (
  organization_id, property_id, profile_id, role, status
) values
  (
    'a1000000-0000-4000-8000-000000000001',
    'b1000000-0000-4000-8000-000000000011',
    'c1000000-0000-4000-8000-000000000101',
    'property_manager',
    'active'
  ),
  (
    'a1000000-0000-4000-8000-000000000001',
    'b1000000-0000-4000-8000-000000000011',
    'c1000000-0000-4000-8000-000000000102',
    'member',
    'active'
  ),
  (
    'a1000000-0000-4000-8000-000000000001',
    'b1000000-0000-4000-8000-000000000011',
    'c1000000-0000-4000-8000-000000000103',
    'member',
    'active'
  );

insert into public.occupancies (
  organization_id,
  property_id,
  unit_id,
  profile_id,
  occupancy_type,
  status
) values (
  'a1000000-0000-4000-8000-000000000001',
  'b1000000-0000-4000-8000-000000000011',
  'f1000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000102',
  'owner',
  'active'
);

-- ---------------------------------------------------------------------------
-- 1–2) Lectura de membresías
-- ---------------------------------------------------------------------------

select tests.authenticate_as('c1000000-0000-4000-8000-000000000102');

select is(
  (
    select count(*)::int
    from public.property_memberships
    where property_id = 'b1000000-0000-4000-8000-000000000011'
  ),
  1,
  '1a residente solo ve su propia membresía en Prop A1'
);

select is(
  (
    select count(*)::int
    from public.occupancies
    where property_id = 'b1000000-0000-4000-8000-000000000011'
  ),
  1,
  '1b residente solo ve su propia occupancy'
);

select tests.authenticate_as('c1000000-0000-4000-8000-000000000101');

select is(
  (
    select count(*)::int
    from public.property_memberships
    where property_id = 'b1000000-0000-4000-8000-000000000011'
  ),
  3,
  '2a manager ve las 3 membresías de Prop A1'
);

select is(
  (
    select count(*)::int
    from public.occupancies
    where property_id = 'b1000000-0000-4000-8000-000000000011'
  ),
  1,
  '2b manager puede leer occupancies de su propiedad'
);

-- ---------------------------------------------------------------------------
-- 3–4) Integridad FK (como postgres; bypass RLS, falla el constraint)
-- ---------------------------------------------------------------------------

select tests.clear_authentication();

select throws_ok(
  $$
    insert into public.property_memberships (
      organization_id, property_id, profile_id, role
    ) values (
      'a1000000-0000-4000-8000-000000000002',
      'b1000000-0000-4000-8000-000000000011',
      'c1000000-0000-4000-8000-000000000104',
      'member'
    )
  $$,
  '23503',
  null,
  '3a membership con organization_id de otra org viola FK compuesta'
);

select throws_ok(
  $$
    insert into public.occupancies (
      organization_id,
      property_id,
      unit_id,
      profile_id,
      occupancy_type,
      status
    ) values (
      'a1000000-0000-4000-8000-000000000002',
      'b1000000-0000-4000-8000-000000000021',
      'f1000000-0000-4000-8000-000000000001',
      'c1000000-0000-4000-8000-000000000103',
      'owner',
      'active'
    )
  $$,
  '23503',
  null,
  '4a occupancy con unit de Prop A1 y property B1 viola FK unit/property'
);

select * from finish();

rollback;
