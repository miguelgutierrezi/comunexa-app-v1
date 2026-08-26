# Modelo de acceso objetivo — Comunexa

Fuente canónica: [`../../supabase/migrations/003_access_model.sql`](../../supabase/migrations/003_access_model.sql).  
Smoke: [`../../supabase/tests/003_access_model_smoke.sql`](../../supabase/tests/003_access_model_smoke.sql).

## Estado

La migración **003** crea el modelo mínimo de identidad/acceso **en paralelo** al legacy 001/002 (`tenants`, `buildings`, `building_admins`, `resident_units`, `profiles.role`).

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

## Profiles

- `profiles.is_platform_superadmin` — privilegio global Comunexa.
- `profiles.role` y `profiles.tenant_id` quedan **legacy** (compat 001/002).
- El acceso operativo no debe inferirse de `profiles.role`.

## Units

`units.property_id` (nullable) puente hacia propiedades hasta el cutover desde `buildings`.

## Preset sembrado

`security_guard` (7 permisos de control de acceso). Ver [`../access-control-and-media.md`](../access-control-and-media.md). También existe el permiso `manage_members` en el catálogo (no incluido en el preset de vigilancia).

## Helpers RLS nuevos

| Función | Uso |
|---|---|
| `has_organization_access(org_id)` | Membresía org o property en esa org |
| `has_property_access(property_id)` | Membresía property, org admin, u occupancy activa |
| `has_property_permission(property_id, code)` | Org admin, property_manager, preset o overrides |
| `is_organization_admin(org_id)` / `is_property_manager(property_id)` | Escritura sin recursión RLS |

## Pendiente

1. Cutover: migrar filas `tenants`→`organizations`, `buildings`→`properties`, `building_admins`/`resident_units`→ memberships/occupancies.
2. Reescribir policies de tablas de negocio (news, visits, …) con helpers de propiedad.
3. Seed Diaz PH sobre el modelo nuevo.
4. Invitaciones / join codes / membership_requests (migración aparte).
