# Brief técnico — Comunexa

Referencia canónica del stack y las decisiones de arquitectura. Los documentos de implementación se derivan de aquí.

## 1. Resumen del producto

Plataforma **SaaS white-label** para administradoras de propiedad horizontal (PH) en LatAm, empezando por **Colombia**. Cliente piloto: **Administradores Diaz PH**.

No es una app de una sola empresa: distintas administradoras (**tenants**) operan sus propios edificios/conjuntos, residentes y datos, **aislados entre sí**, bajo su propia marca dentro de la misma base de código.

**Jerarquía de acceso objetivo:** Superadmin de plataforma · Administrador de organización · Responsable de propiedad · Operador de propiedad · Miembro/cliente. Los permisos de organización y propiedad se asignan mediante membresías, no como un único rol global en el perfil.

**Funcionalidades principales:** cartelera/noticias · reservas de zonas comunes · mensajería interna · registro de visitas con reporte PDF · facturación/cuotas · PQR · votaciones/asambleas · gestión de edificios/residentes/administradores · notificaciones push por edificio.

**Control de acceso:** vigilancia es `property_staff` con preset `security_guard`, limitado a visitas, vehículos, autorizaciones y eventos de entrada/salida. No es un rol global adicional. Detalle en [`access-control-and-media.md`](access-control-and-media.md).

**Distribución:** la misma base Flutter se publica en **tres canales** — Google Play, App Store y versión web. **No hay pagos dentro de la app por ahora** (se retoma más adelante; ver §6).

**Modelo comercial objetivo:** suscripción B2B pagada por la organización o por la propiedad/conjunto, basada en cargo base + unidades activas + complementos. Puede cubrir una o varias propiedades. Durante el piloto se factura y activa manualmente; el usuario final no paga por acceso. Es independiente de cuotas o pagos de residentes, que continúan pausados. Detalle en [`subscriptions-and-onboarding.md`](subscriptions-and-onboarding.md).

**Etapa:** pre-producción. Fundamentos + UI de login + **home shell mock** (móvil / tablet landscape / desktop) listos; Auth Supabase y módulos de negocio reales pendientes (ver [`roadmap.md`](roadmap.md)). Base reutilizable para muchas administradoras, no solo el cliente piloto.

## 2. Stack tecnológico

| Capa | Elección | Por qué |
|---|---|---|
| App móvil + web | **Flutter** (incl. Flutter Web) | Un solo lenguaje (Dart) para iOS, Android y web. Compila a nativo real, consistencia visual, menor fragmentación que RN. |
| Backend / BD | **Supabase (Postgres)** | Datos relacionales y transaccionales. JOINs y ACID. **RLS** para multi-tenant y permisos. |
| Autenticación | **Supabase Auth** | Integrado con RLS vía `auth.uid()`. |
| Archivos | **Supabase Storage** | Logos, adjuntos PQR, PDFs, documentos — políticas por tenant/edificio. |
| Lógica server-side | **Supabase Edge Functions** (Deno) | PDF, push, jobs (`pg_cron`); webhook de pagos como stub hasta v2 de cobros. |
| Push | **FCM** (solo ese servicio Firebase) | Estándar de facto, gratis a escala. Backend sigue siendo Supabase. |
| Pagos | **Pausado** — a futuro Wompi o PayU | v1: módulo `invoices`/`payments` en esquema, **sin** cobro in-app. |
| Estado (Flutter) | **Riverpod** | Predecible, testeable. |
| Navegación | **go_router** | Deep linking para push. |
| Modelos | **freezed + json_serializable** | Inmutables desde esquema Supabase. |
| Hosting web | **Firebase Hosting** | Plan gratis sin restricción comercial (a diferencia de Vercel Hobby). 10 GB + 360 MB/día; build estático. Reutiliza la cuenta Firebase de FCM. |
| CI/CD (Android, iOS, Web) | **GitHub Actions** | Tres workflows en el mismo repo. Ver §7. |
| Tiendas | Apple Developer + Google Play | Requisito de plataforma. |

## 3. Arquitectura multi-tenant y multi-propiedad

**Decisión clave:** un solo proyecto Supabase, **no** uno por administradora. Aislamiento a **nivel de fila** (RLS).

- Cada empresa cliente = una **organización**; mientras se migra el esquema, su nombre físico sigue siendo `tenants`.
- Cada organización administra varias **propiedades**: edificio, conjunto residencial y, como extensión futura, hotel. El nombre físico actual es `buildings`; el objetivo es `properties` con `property_type`.
- Tablas de negocio con `tenant_id` y propiedad/unidad cuando aplique.
- **RLS** por `tenant_id` y rol.
- **Marca dinámica jerárquica:** un solo build Flutter; la propiedad puede aportar identidad visual, con fallback a la organización y finalmente a Comunexa.

La terminología neutral de dominio es `organization` / `property` / `unit`. Los nombres actuales `tenant` / `building` se conservan hasta ejecutar una migración explícita; no deben mezclarse ambos modelos parcialmente.

**Alternativa futura:** flavors white-label por cliente enterprise — no es la base por defecto.

### Branding efectivo

La modalidad predeterminada es **co-branding**: la propiedad ocupa el primer plano, la organización aparece como administradora y Comunexa conserva una firma discreta como plataforma. Modos previstos:

- `inherit`: la propiedad hereda la identidad de su organización.
- `co_branded`: identidad de propiedad + referencia a organización + “Tecnología Comunexa”; recomendado.
- `white_label`: retira la presencia visible de Comunexa; reservado para un plan enterprise futuro.

La personalización admite logo, nombre visible, colores validados, portada y contacto. Tipografía, estructura, iconografía, accesibilidad y componentes permanecen controlados por el producto.

Las imágenes configurables se validan y re-encodean en backend; la app solo consume variantes procesadas. PNG/JPEG/WebP son la allowlist MVP y no se aceptan SVG subidos por usuarios.

## 4. Roles, membresías y permisos

| Rol funcional | Identificador objetivo | Alcance | Acciones típicas |
|---|---|---|---|
| Superadmin de plataforma | `platform_superadmin` | Global | Crea organizaciones, soporte y métricas; no es un administrador de propiedad |
| Administrador de organización | `organization_admin` | Toda su organización | Propiedades, usuarios, marca y operación global |
| Responsable de propiedad | `property_manager` | Propiedades asignadas | Configuración y administración completa de la propiedad |
| Operador de propiedad | `property_staff` | Propiedades asignadas | Operación delegada: visitas, PQR, reservas o recepción |
| Miembro / cliente | `member` | Unidades u ocupaciones asociadas | Noticias, reservas, facturas, PQR, votaciones y visitas propias |

**Decisión objetivo:** `profiles` representa identidad y datos personales; el acceso vive en `organization_memberships` y `property_memberships`. Esto permite que una persona tenga roles distintos en propiedades diferentes. `platform_superadmin` permanece como privilegio global separado.

**Estado SQL actual:** `profiles.tenant_id` + `profiles.role`, con `building_admins` y `resident_units`. Es suficiente para el prototipo PH, pero debe migrarse antes de Auth real. Hoteles son una extensión prevista, no alcance del MVP actual.

## 5. Entidades principales

Detalle: [`database/schema.sql`](database/schema.sql), [`database/er-diagram.md`](database/er-diagram.md).

`tenants` · `buildings` · `units` · `profiles` · `building_admins` · `resident_units` · `invoices` · `payments` · `pqr` · `news` · `common_areas` · `reservations` · `visits` · `messages` · `polls` · `poll_options` · `votes` · `notifications_log`

Entidades objetivo pendientes de migración: suscripciones/entitlements, invitaciones privadas, códigos públicos de propiedad, solicitudes de membresía, ocupaciones con vigencia, visitantes, vehículos, autorizaciones y eventos de acceso.

## 6. Integraciones externas

- **FCM:** token por usuario; Edge Function al publicar noticia, responder PQR, aprobar visita o generar cuota — por edificio/unidad.
- **PDF:** Edge Function → Storage → URL firmada.
- **Pasarela (Wompi/PayU) — pausado:** no entra en v1. Cuando se active: checkout → webhook Edge Function → `invoices`/`payments` → comprobante en Storage. El diseño del esquema no cambia; `payment-webhook` queda como **stub**.

## 7. Entornos y CI/CD

**Decisión actual (pre-producción):** **un solo ambiente** — un proyecto Supabase y un proyecto Firebase (FCM + Hosting). No hay staging/prod separados: la app aún no está en producción. Separar ambientes cuando haya piloto con datos reales (ver roadmap).

- **GitHub Actions** — tres workflows ([`.github/workflows/`](../.github/workflows/), [`ci-cd.md`](ci-cd.md)):

| Workflow | Disparo | Resultado |
|---|---|---|
| `web.yml` | Push a `main` | `flutter build web` → **Firebase Hosting** |
| `android.yml` | Tag `v*` **y** `ENABLE_ANDROID_CI=true` | AAB → Play internal (off por defecto) |
| `ios.yml` | Tag `v*` **y** `ENABLE_IOS_CI=true` | TestFlight (off por defecto; ahorra macOS) |

Publicación a stores públicas = paso manual. Migraciones en `supabase/migrations/`.

**Costo:** macOS ≈ 10× minutos Linux → `ios.yml` solo por tag y solo con flag activo.

## 8. Mapa de documentación

| Entregable | Ubicación |
|---|---|
| Esquema SQL | [`database/schema.sql`](database/schema.sql) · [`../supabase/migrations/`](../supabase/migrations/) |
| RLS | [`database/rls-policies.md`](database/rls-policies.md) |
| Diagrama ER | [`database/er-diagram.md`](database/er-diagram.md) |
| Flutter | [`flutter-structure.md`](flutter-structure.md) |
| Edge Functions | [`supabase-functions.md`](supabase-functions.md) |
| CI/CD | [`ci-cd.md`](ci-cd.md) · [`.github/workflows/`](../.github/workflows/) |
| Setup | [`setup.md`](setup.md) |
| Convenciones | [`conventions.md`](conventions.md) |
| Agentes IA | [`../AGENTS.md`](../AGENTS.md) · [`../CLAUDE.md`](../CLAUDE.md) · [`../.cursor/rules/`](../.cursor/rules/) · [`../.github/copilot-instructions.md`](../.github/copilot-instructions.md) |
