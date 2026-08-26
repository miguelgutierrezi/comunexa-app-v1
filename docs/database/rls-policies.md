# Políticas RLS — Comunexa

Row Level Security en Postgres (Supabase).

| Capa | Fuente |
|---|---|
| Legacy (tenants/buildings) | [`../../supabase/migrations/002_rls_policies.sql`](../../supabase/migrations/002_rls_policies.sql) |
| Acceso objetivo (org/property) | [`003`](../../supabase/migrations/003_access_model.sql) + grants [`004`](../../supabase/migrations/004_access_model_grants.sql) + integridad/SELECT [`005`](../../supabase/migrations/005_access_integrity_and_membership_rls.sql) |
| Tests | [`004_access_model_rls.test.sql`](../../supabase/tests/004_access_model_rls.test.sql) · [`005_access_integrity_rls.test.sql`](../../supabase/tests/005_access_integrity_rls.test.sql) · CI [`.github/workflows/rls.yml`](../../.github/workflows/rls.yml) |

## Principio

El aislamiento multi-tenant **no depende del cliente Flutter**. Cada query pasa por Postgres con el JWT de Supabase Auth; las policies deciden qué filas ve o modifica el usuario.

## Funciones helper

| Función | Uso |
|---|---|
| `current_profile()` | Perfil del usuario autenticado |
| `current_role()` | Rol enum (`user_role`) |
| `current_tenant_id()` | UUID del tenant asignado |
| `is_platform_superadmin()` | Acceso global |
| `has_building_access(building_id)` | Residente, admin de edificio, admin de tenant o superadmin |
| `has_unit_access(unit_id)` | Acceso vía edificio de la unidad |

## Matriz de acceso por rol

| Recurso | Superadmin | Tenant admin | Building admin | Residente |
|---|---|---|---|---|
| `tenants` | CRUD | R/U propio | R propio | R propio (marca) |
| `buildings` | CRUD | CRUD tenant | R edificios asignados | R su edificio |
| `units` | CRUD | CRUD | CRUD edificios asignados | R su unidad |
| `profiles` | CRUD | R/U tenant | R colegas edificio | R/U propio |
| `news` | CRUD | CRUD | CRUD | R |
| `reservations` | CRUD | CRUD | U estado | C/R propias |
| `pqr` | CRUD | CRUD | U/asignar | C/R propias |
| `invoices` | CRUD | CRUD | CRUD | R propias |
| `votes` | CRUD | CRUD | CRUD | C/R (1 voto/unidad) |
| `visits` | CRUD | CRUD | U | C/R propias |

## Casos de prueba obligatorios

### Modelo objetivo (003–005) — automatizados

```bash
supabase start && supabase test db
# o, tras cambios de migración: supabase db reset && supabase test db
```

1. Aislamiento entre organizaciones.
2. Manager solo en propiedades asignadas.
3. Residente sin crear/actualizar propiedades ni asignar managers.
4. Multirrol: administra solo donde es `property_manager`.
5. Autenticado sin membresías: 0 orgs/properties; catálogo de permisos sí.
6. **(005)** Residente no enumera membresías/occupancies ajenas; manager sí lista las de su propiedad.
7. **(005)** FK compuesta rechaza `organization_id` / `unit_id` inconsistentes con la propiedad.

### Legacy / producción (manual o ampliar suite)

1. Usuario tenant A **no** lee filas con `tenant_id` de tenant B.
2. Residente **no** inserta noticia en edificio ajeno.
3. Building admin **no** accede edificio no asignado.
4. Residente **no** vota dos veces (constraint + policy).
5. Usuario anónimo **no** lee tablas de negocio.

## Storage (complemento)

RLS de Postgres no aplica a Storage. Buckets con políticas equivalentes:

```sql
-- Ejemplo conceptual en storage.objects
-- tenant-assets: lectura pública del logo; escritura solo tenant_admin
-- property-assets: lectura autenticada; escritura organization_admin/property_manager de esa propiedad
-- building-docs: lectura si has_building_access; escritura admin
```

Definir en migración `003_storage_policies.sql` cuando se creen los buckets.

## Evolución

### Migración 003 (hecha) — modelo objetivo mínimo

Ver [`access-model.md`](access-model.md) y [`../../supabase/migrations/003_access_model.sql`](../../supabase/migrations/003_access_model.sql).

Helpers nuevas: `has_organization_access`, `has_property_access`, `has_property_permission`; `is_platform_superadmin()` también mira `profiles.is_platform_superadmin`.

### Migración 005 (hecha) — integridad + SELECT de membresías

- FKs compuestas `property_memberships` / `occupancies` → `properties (id, organization_id)`.
- FK `occupancies (unit_id, property_id)` → `units (id, property_id)`.
- Helper `can_manage_property_members(property_id)`.
- SELECT de membresías/occupancies: propia fila o gestores; **no** `has_property_access`.

### Cutover pendiente

La matriz superior refleja policies **002** (legacy). Falta:

1. migrar datos tenants/buildings → organizations/properties;
2. reescribir policies de tablas de negocio con helpers de propiedad;
3. ampliar tests a news/visits y `security_guard` (no borrar historial).

Definir Storage buckets (`property-assets`) en migración dedicada cuando se creen.
