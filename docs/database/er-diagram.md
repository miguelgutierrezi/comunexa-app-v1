# Diagrama entidad-relación — Comunexa

Esquema Postgres en Supabase.

> **Estado:** migraciones **001/002** = dominio legacy (`tenants`/`buildings`). Migración **003** = modelo objetivo de identidad/acceso (`organizations`/`properties`/memberships). Detalle: [`access-model.md`](access-model.md). No editar migraciones ya aplicadas.

## Modelo objetivo de identidad y acceso (003)

```mermaid
erDiagram
  organizations ||--o{ organization_memberships : tiene
  organizations ||--o{ properties : administra
  properties ||--o{ property_memberships : autoriza
  properties ||--o{ occupancies : contextualiza
  permission_presets ||--o{ permission_preset_permissions : agrupa
  permissions ||--o{ permission_preset_permissions : incluye
  permission_presets ||--o{ property_memberships : opcional
  property_memberships ||--o{ property_membership_permissions : overrides
  permissions ||--o{ property_membership_permissions : concede
  profiles ||--o{ organization_memberships : participa
  profiles ||--o{ property_memberships : participa
  profiles ||--o{ occupancies : ocupa
  units ||--o{ occupancies : recibe
  properties ||--o{ units : puente_nullable
```

- `profiles.is_platform_superadmin` es el privilegio global; `profiles.role` es legacy.
- `organization_memberships.role`: `organization_admin` o `member`.
- `property_memberships.role`: `property_manager`, `property_staff` o `member`.
- `property_staff` usa `permission_preset_id` (p. ej. `security_guard`) y/o overrides.
- `properties.property_type`: `building` / `residential_complex`; `hotel` reservado.
- `occupancies`: tipo + vigencia + estado; historial al cerrar.

Legacy vigente en paralelo hasta cutover: `tenants`, `buildings`, `building_admins`, `resident_units`.

Pendiente de migraciones futuras (no en 003):

- `billing_accounts` / suscripción;
- `property_join_codes`, `property_invitations`, `membership_requests`;
- `visitors`, `vehicles`, `visit_authorizations`, `access_events`.

Detalle: [`../subscriptions-and-onboarding.md`](../subscriptions-and-onboarding.md) · [`../access-control-and-media.md`](../access-control-and-media.md) · [`access-model.md`](access-model.md).

## Diagrama principal (legacy 001/002)

```mermaid
erDiagram
  tenants ||--o{ buildings : tiene
  tenants ||--o{ profiles : emplea
  buildings ||--o{ units : contiene
  buildings ||--o{ news : publica
  buildings ||--o{ common_areas : ofrece
  buildings ||--o{ visits : registra
  buildings ||--o{ polls : convoca
  buildings ||--o{ building_admins : asigna

  profiles ||--o{ building_admins : administra
  profiles ||--o{ resident_units : habita
  units ||--o{ resident_units : ocupa
  units ||--o{ invoices : factura
  units ||--o{ pqr : reporta
  units ||--o{ reservations : reserva
  units ||--o{ visits : recibe
  units ||--o{ votes : emite

  invoices ||--o{ payments : liquida
  common_areas ||--o{ reservations : agenda
  polls ||--o{ poll_options : ofrece
  poll_options ||--o{ votes : recibe
  message_threads ||--o{ messages : contiene
  profiles ||--o{ messages : envia

  tenants {
    uuid id PK
    text name
    text slug UK
    text logo_url
    text primary_color
    boolean active
  }

  buildings {
    uuid id PK
    uuid tenant_id FK
    text name
    text city
  }

  units {
    uuid id PK
    uuid tenant_id FK
    uuid building_id FK
    text identifier
  }

  profiles {
    uuid id PK
    uuid tenant_id FK
    user_role role
    text full_name
    text fcm_token
  }

  invoices {
    uuid id PK
    uuid unit_id FK
    numeric amount
    invoice_status status
  }

  pqr {
    uuid id PK
    uuid unit_id FK
    pqr_status status
  }
```

## Agrupación por dominio

| Dominio | Tablas |
|---|---|
| Plataforma / tenant | `tenants` |
| Estructura física | `buildings`, `units` |
| Usuarios y acceso | `profiles`, `building_admins`, `resident_units` |
| Finanzas | `invoices`, `payments` |
| Operación | `news`, `common_areas`, `reservations`, `visits`, `pqr` |
| Comunicación | `message_threads`, `messages`, `notifications_log` |
| Gobernanza | `polls`, `poll_options`, `votes` |

## Reglas de diseño

1. **`tenant_id` redundante** en tablas hijas de `buildings` / `units` para simplificar políticas RLS sin JOINs profundos en cada policy.
2. **`profiles.id`** = `auth.users.id` (Supabase Auth).
3. **Un voto por unidad por encuesta** — constraint `unique (poll_id, unit_id)` en `votes`.
4. **Identificador de unidad** único por edificio — `unique (building_id, identifier)`.

## Archivos SQL

- Esquema legacy: [`../../supabase/migrations/001_initial_schema.sql`](../../supabase/migrations/001_initial_schema.sql)
- RLS legacy: [`../../supabase/migrations/002_rls_policies.sql`](../../supabase/migrations/002_rls_policies.sql)
- Acceso objetivo: [`../../supabase/migrations/003_access_model.sql`](../../supabase/migrations/003_access_model.sql)
- Resumen acceso: [`access-model.md`](access-model.md)
- Copia de referencia legacy: [`schema.sql`](schema.sql)

## Storage (Supabase, no ER)

Buckets previstos:

| Bucket | Ruta ejemplo | Contenido |
|---|---|---|
| `tenant-assets` | `{tenant_id}/logo.png` | Logos de marca |
| `property-assets` (objetivo) | `{tenant_id}/{property_id}/branding/{asset}` | Logo y portada de la propiedad; crear con la migración de propiedades |
| `building-docs` | `{tenant_id}/{building_id}/visits/{id}.pdf` | PDFs de visitas |
| `pqr-attachments` | `{tenant_id}/{pqr_id}/...` | Adjuntos PQR |

Políticas de Storage en [`../security.md`](../security.md).
