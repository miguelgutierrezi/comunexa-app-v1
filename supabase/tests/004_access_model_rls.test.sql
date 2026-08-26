-- pgTAP: RLS del modelo de acceso (003)
-- Escenarios:
-- 1) aislamiento entre organizaciones
-- 2) manager solo en propiedades asignadas
-- 3) residente sin acceso administrativo
-- 4) usuario multirrol con permisos distintos
-- 5) autenticado sin membresías
--
-- Ejecutar: supabase start && supabase test db

begin;

create extension if not exists pgtap with schema extensions;

select plan(20);

-- ---------------------------------------------------------------------------
-- Helpers locales (sin depender de dbdev)
-- ---------------------------------------------------------------------------

create schema if not exists tests;

create or replace function tests.create_user(p_id uuid, p_email text)
returns void
language plpgsql
security definer
set search_path = public, auth
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
  -- INVOKER: SET ROLE no está permitido en SECURITY DEFINER (PG).
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
  -- INVOKER: vuelve al rol de sesión (postgres en CI) para bypass RLS.
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claim.role', '', true);
  perform set_config('request.jwt.claims', '', true);
  execute 'reset role';
end;
$$;

-- ---------------------------------------------------------------------------
-- Fixtures (como postgres; bypass RLS)
-- ---------------------------------------------------------------------------

select tests.clear_authentication();

-- IDs fijos
-- org A / B
-- props: A1, A2 (org A), B1 (org B)
-- users: manager_a1, resident_a1, multirole, orphan

select tests.create_user(
  'c0000000-0000-4000-8000-000000000101',
  'manager_a1@test.comunexa.local'
);
select tests.create_user(
  'c0000000-0000-4000-8000-000000000102',
  'resident_a1@test.comunexa.local'
);
select tests.create_user(
  'c0000000-0000-4000-8000-000000000103',
  'multirole@test.comunexa.local'
);
select tests.create_user(
  'c0000000-0000-4000-8000-000000000104',
  'orphan@test.comunexa.local'
);

insert into public.organizations (id, name, slug)
values
  ('a0000000-0000-4000-8000-000000000001', 'Org Alpha', 'org-alpha'),
  ('a0000000-0000-4000-8000-000000000002', 'Org Beta', 'org-beta')
on conflict (id) do nothing;

insert into public.properties (
  id, organization_id, name, property_type, branding_mode
) values
  (
    'b0000000-0000-4000-8000-000000000011',
    'a0000000-0000-4000-8000-000000000001',
    'Prop A1',
    'building',
    'co_branded'
  ),
  (
    'b0000000-0000-4000-8000-000000000012',
    'a0000000-0000-4000-8000-000000000001',
    'Prop A2',
    'building',
    'co_branded'
  ),
  (
    'b0000000-0000-4000-8000-000000000021',
    'a0000000-0000-4000-8000-000000000002',
    'Prop B1',
    'building',
    'co_branded'
  )
on conflict (id) do nothing;

-- Legacy tenant/building/unit para occupancy
insert into public.tenants (id, name, slug)
values (
  'd0000000-0000-4000-8000-000000000001',
  'Legacy Tenant Alpha',
  'legacy-alpha'
)
on conflict (id) do nothing;

insert into public.buildings (id, tenant_id, name)
values (
  'e0000000-0000-4000-8000-000000000001',
  'd0000000-0000-4000-8000-000000000001',
  'Legacy Building A1'
)
on conflict (id) do nothing;

insert into public.units (
  id, tenant_id, building_id, identifier, property_id
) values (
  'f0000000-0000-4000-8000-000000000001',
  'd0000000-0000-4000-8000-000000000001',
  'e0000000-0000-4000-8000-000000000001',
  '101',
  'b0000000-0000-4000-8000-000000000011'
)
on conflict (id) do nothing;

insert into public.property_memberships (
  organization_id, property_id, profile_id, role, status
) values
  (
    'a0000000-0000-4000-8000-000000000001',
    'b0000000-0000-4000-8000-000000000011',
    'c0000000-0000-4000-8000-000000000101',
    'property_manager',
    'active'
  ),
  (
    'a0000000-0000-4000-8000-000000000001',
    'b0000000-0000-4000-8000-000000000011',
    'c0000000-0000-4000-8000-000000000102',
    'member',
    'active'
  ),
  (
    'a0000000-0000-4000-8000-000000000001',
    'b0000000-0000-4000-8000-000000000011',
    'c0000000-0000-4000-8000-000000000103',
    'property_manager',
    'active'
  ),
  (
    'a0000000-0000-4000-8000-000000000001',
    'b0000000-0000-4000-8000-000000000012',
    'c0000000-0000-4000-8000-000000000103',
    'member',
    'active'
  )
on conflict (property_id, profile_id) do nothing;

insert into public.occupancies (
  organization_id,
  property_id,
  unit_id,
  profile_id,
  occupancy_type,
  status
) values (
  'a0000000-0000-4000-8000-000000000001',
  'b0000000-0000-4000-8000-000000000011',
  'f0000000-0000-4000-8000-000000000001',
  'c0000000-0000-4000-8000-000000000102',
  'owner',
  'active'
);

-- ---------------------------------------------------------------------------
-- 1) Aislamiento entre organizaciones
-- ---------------------------------------------------------------------------

select tests.authenticate_as('c0000000-0000-4000-8000-000000000101');

select is(
  (select count(*)::int from public.organizations),
  1,
  '1a manager A1 ve solo su organización'
);

select is(
  (select count(*)::int from public.properties),
  1,
  '1b manager A1 ve solo Prop A1 (no A2 ni B1)'
);

select is(
  (
    select count(*)::int
    from public.properties
    where id = 'b0000000-0000-4000-8000-000000000021'
  ),
  0,
  '1c manager A1 no ve Prop B1 de otra org'
);

-- ---------------------------------------------------------------------------
-- 2) Manager solo en propiedades asignadas
-- ---------------------------------------------------------------------------

select lives_ok(
  $$
    update public.properties
    set name = 'Prop A1 Updated'
    where id = 'b0000000-0000-4000-8000-000000000011'
  $$,
  '2a manager puede actualizar Prop A1 asignada'
);

select is(
  (
    select name from public.properties
    where id = 'b0000000-0000-4000-8000-000000000011'
  ),
  'Prop A1 Updated',
  '2b nombre de Prop A1 quedó actualizado'
);

select lives_ok(
  $$
    update public.properties
    set name = 'HACK A2'
    where id = 'b0000000-0000-4000-8000-000000000012'
  $$,
  '2c update a Prop A2 no asignada no lanza (0 filas por RLS)'
);

select tests.clear_authentication();
select is(
  (
    select name from public.properties
    where id = 'b0000000-0000-4000-8000-000000000012'
  ),
  'Prop A2',
  '2d Prop A2 no fue modificada por manager de A1'
);

-- ---------------------------------------------------------------------------
-- 3) Residente sin acceso administrativo
-- ---------------------------------------------------------------------------

select tests.authenticate_as('c0000000-0000-4000-8000-000000000102');

select is(
  (
    select count(*)::int from public.properties
    where id = 'b0000000-0000-4000-8000-000000000011'
  ),
  1,
  '3a residente puede leer su propiedad'
);

select throws_ok(
  $$
    insert into public.properties (
      organization_id, name, property_type
    ) values (
      'a0000000-0000-4000-8000-000000000001',
      'Illegal Prop',
      'building'
    )
  $$,
  '42501',
  null,
  '3b residente no puede crear propiedades'
);

select lives_ok(
  $$
    update public.properties
    set name = 'HACK BY RESIDENT'
    where id = 'b0000000-0000-4000-8000-000000000011'
  $$,
  '3c update admin como residente no lanza (0 filas)'
);

select tests.clear_authentication();
select is(
  (
    select name from public.properties
    where id = 'b0000000-0000-4000-8000-000000000011'
  ),
  'Prop A1 Updated',
  '3d residente no pudo renombrar la propiedad'
);

select tests.authenticate_as('c0000000-0000-4000-8000-000000000102');
select throws_ok(
  $$
    insert into public.property_memberships (
      organization_id, property_id, profile_id, role
    ) values (
      'a0000000-0000-4000-8000-000000000001',
      'b0000000-0000-4000-8000-000000000011',
      'c0000000-0000-4000-8000-000000000104',
      'property_manager'
    )
  $$,
  '42501',
  null,
  '3e residente no puede asignar managers'
);

-- ---------------------------------------------------------------------------
-- 4) Multirrol: manager en A1, member en A2
-- ---------------------------------------------------------------------------

select tests.authenticate_as('c0000000-0000-4000-8000-000000000103');

select is(
  (select count(*)::int from public.properties),
  2,
  '4a multirrol ve Prop A1 y A2'
);

select lives_ok(
  $$
    update public.properties
    set name = 'Prop A1 Multi'
    where id = 'b0000000-0000-4000-8000-000000000011'
  $$,
  '4b multirrol puede actualizar A1 (manager)'
);

select lives_ok(
  $$
    update public.properties
    set name = 'HACK A2 MULTI'
    where id = 'b0000000-0000-4000-8000-000000000012'
  $$,
  '4c update A2 como member no lanza (0 filas)'
);

select tests.clear_authentication();
select is(
  (
    select name from public.properties
    where id = 'b0000000-0000-4000-8000-000000000012'
  ),
  'Prop A2',
  '4d multirrol no pudo administrar A2 donde solo es member'
);

select is(
  (
    select name from public.properties
    where id = 'b0000000-0000-4000-8000-000000000011'
  ),
  'Prop A1 Multi',
  '4e multirrol sí administró A1'
);

-- ---------------------------------------------------------------------------
-- 5) Autenticado sin membresías
-- ---------------------------------------------------------------------------

select tests.authenticate_as('c0000000-0000-4000-8000-000000000104');

select is(
  (select count(*)::int from public.organizations),
  0,
  '5a huérfano no ve organizaciones'
);

select is(
  (select count(*)::int from public.properties),
  0,
  '5b huérfano no ve propiedades'
);

select ok(
  (select count(*)::int from public.permissions) > 0,
  '5c huérfano sí puede leer catálogo de permisos'
);

select * from finish();

rollback;
