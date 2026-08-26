# Modelo de acceso objetivo — Comunexa

Fuente canónica: [`../../supabase/migrations/003_access_model.sql`](../../supabase/migrations/003_access_model.sql).  
Integridad + SELECT estricto: [`../../supabase/migrations/005_access_integrity_and_membership_rls.sql`](../../supabase/migrations/005_access_integrity_and_membership_rls.sql).  
Grants: [`../../supabase/migrations/004_access_model_grants.sql`](../../supabase/migrations/004_access_model_grants.sql).  
Tests RLS (pgTAP): `004_access_model_rls.test.sql` · `005_access_integrity_rls.test.sql` — `supabase test db`.  
Smoke schema: [`../../supabase/scripts/003_access_model_smoke.sql`](../../supabase/scripts/003_access_model_smoke.sql).

## Estado

La migración **003** crea el modelo mínimo de identidad/acceso **en paralelo** al legacy 001/002 (`tenants`, `buildings`, `building_admins`, `resident_units`, `profiles.role`).

**005** añade FKs compuestas (coherencia org↔propiedad↔unidad) y estrecha el SELECT de membresías/occupancies.

No hace cutover de datos ni elimina tablas legacy. Eso es una migración posterior (seed Diaz PH + reescritura de policies de dominio).

## Tablas

| Tabla | Rol |
|---|---|
| `organizations` | Administradora / cliente B2B |
| `properties` | Edificio o conjunto (`property_type`; `hotel` reservado) |
| `organization_memberships` | Rol en org: `organization_admin` \| `member` |
| `property_memberships` | Rol en propiedad: `property_manager` \| `property_staff` \| `member` |
| `property_membership_permissions` | Permisos explícitos por membresía |
| `occupancies` | Vínculo perfil↔unidad con vigencia/estado |
| `permissions` / `permission_presets` / `permission_preset_permissions` | Catálogo + presets |

## Integridad (005)

| Constraint | Garantía |
|---|---|
| `properties (id, organization_id)` UNIQUE | Base para FK compuesta |
| `property_memberships (property_id, organization_id)` → `properties` | Org de la membresía = org de la propiedad |
| `occupancies (property_id, organization_id)` → `properties` | Igual para ocupaciones |
| `units (id, property_id)` UNIQUE | Base para FK unidad↔propiedad |
| `occupancies (unit_id, property_id)` → `units` | La unidad pertenece a esa propiedad |

RLS **no** es la única protección contra filas inconsistentes.

## Profiles

- `profiles.is_platform_superadmin` — privilegio global Comunexa.
- `profiles.role` y `profiles.tenant_id` quedan **legacy** (compat 001/002).
- El acceso operativo no debe inferirse de `profiles.role`.

## Units

`units.property_id` (nullable) puente hacia propiedades hasta el cutover desde `buildings`. Las ocupaciones exigen `property_id` coherente vía FK.

## Preset sembrado

`security_guard` (7 permisos de control de acceso). Ver [`../access-control-and-media.md`](../access-control-and-media.md). También existe el permiso `manage_members` en el catálogo (no incluido en el preset de vigilancia).

## Helpers RLS

| Función | Uso |
|---|---|
| `has_organization_access(org_id)` | Membresía org o property en esa org |
| `has_property_access(property_id)` | Membresía property, org admin, u occupancy activa |
| `has_property_permission(property_id, code)` | Org admin, property_manager, preset o overrides |
| `is_organization_admin(org_id)` / `is_property_manager(property_id)` | Escritura sin recursión RLS |
| `can_manage_property_members(property_id)` **(005)** | Listar membresías/occupancies ajenas |

## Lectura de membresías (005)

- Cada usuario lee **su** fila (`profile_id = auth.uid()`).
- Listado ajeno solo si `can_manage_property_members` (org admin, property_manager o `manage_members`).
- Un residente **no** enumera roles de vecinos. Un directorio de residentes requiere vista/RPC dedicada (pendiente).

## Flutter (cierre A–E)

Implementado en app:

| Pieza | Ubicación |
|---|---|
| `AccessContextRepository` | `lib/features/auth/data/` (Supabase + Fake) |
| `SessionNotifier` + `lastContextId` | `lib/core/session/` |
| `/no-access` | `no_access_screen.dart` |
| `/reset-password` + `onAuthStateChange` | `reset_password_screen.dart` + `SupabaseAuthRepository` |
| Seed E2E manual | [`../../supabase/scripts/006_e2e_access_seed.sql`](../../supabase/scripts/006_e2e_access_seed.sql) |
| Guía validación | [`../access-model-e2e-validation.md`](../access-model-e2e-validation.md) |

## Pendiente (post-E)

1. Cutover: migrar filas `tenants`→`organizations`, `buildings`→`properties`, `building_admins`/`resident_units`→ memberships/occupancies.
2. Reescribir policies de tablas de negocio (news, visits, …) con helpers de propiedad.
3. Seed Diaz PH sobre el modelo nuevo.
4. Invitaciones / join codes / membership_requests (migración aparte).

## Tests RLS

**004** — aislamiento org, manager asignado, residente, multirrol, huérfano.  
**005** — no enumeración residente; manager lista; FK org inconsistente; FK unit/property inconsistente.
