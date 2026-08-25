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
-- property-assets: lectura autenticada; escritura organization_admin/property_manager de esa propiedad
-- building-docs: lectura si has_building_access; escritura admin
```

Definir en migración `003_storage_policies.sql` cuando se creen los buckets.

## Evolución

### Migración de roles pendiente antes de Auth

La matriz anterior refleja las policies 002 actuales. El objetivo aprobado reemplaza el rol único de `profiles` por membresías:

- privilegio global: `platform_superadmin`;
- organización: `organization_admin`;
- propiedad: `property_manager`, `property_staff`, `member`.

Las helpers futuras deben resolver acceso para una propiedad concreta y no inferir que un usuario tiene el mismo rol en toda la organización. Los tests deben incluir un usuario con roles distintos en dos propiedades y verificar que los permisos no se propaguen entre ellas.

Las invitaciones y solicitudes requieren pruebas adicionales: un código público no permite leer datos privados; un miembro no se autoaprueba; un manager no aprueba fuera de sus propiedades; un token expirado/revocado no crea membresía; y la activación de plan no depende de valores enviados por Flutter.

Para control de acceso, `property_staff` requiere permisos explícitos del preset `security_guard`. Debe poder registrar entradas/salidas solo en propiedades asignadas, sin leer dominios ajenos ni borrar historial. Las correcciones son eventos auditables, no `DELETE` operativo.

Al añadir tablas nuevas:

1. Columna `tenant_id` (y FKs a building/unit según aplique).
2. `enable row level security`.
3. Policies usando helpers existentes.
4. Test cross-tenant en CI.
