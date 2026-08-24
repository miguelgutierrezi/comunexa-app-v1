# Políticas RLS — Comunexa

Row Level Security en Postgres (Supabase). Fuente canónica: [`../../supabase/migrations/002_rls_policies.sql`](../../supabase/migrations/002_rls_policies.sql).

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

Antes de producción, validar con tests (p. ej. `supabase test` o script con usuarios de prueba):

1. Usuario tenant A **no** lee filas con `tenant_id` de tenant B.
2. Residente **no** inserta noticia en edificio ajeno.
3. Building admin **no** accede edificio no asignado en `building_admins`.
4. Residente **no** vota dos veces en la misma encuesta (constraint + policy).
5. Usuario anónimo **no** lee ninguna tabla de negocio.

## Storage (complemento)

RLS de Postgres no aplica a Storage. Buckets con políticas equivalentes:

```sql
-- Ejemplo conceptual en storage.objects
-- tenant-assets: lectura pública del logo; escritura solo tenant_admin
-- building-docs: lectura si has_building_access; escritura admin
```

Definir en migración `003_storage_policies.sql` cuando se creen los buckets.

## Evolución

Al añadir tablas nuevas:

1. Columna `tenant_id` (y FKs a building/unit según aplique).
2. `enable row level security`.
3. Policies usando helpers existentes.
4. Test cross-tenant en CI.
