# Brief técnico — Comunexa

Referencia canónica del stack y las decisiones de arquitectura. Los documentos de implementación se derivan de aquí.

## 1. Resumen del producto

Plataforma **SaaS white-label** para administradoras de propiedad horizontal (PH) en LatAm, empezando por **Colombia**. Cliente piloto: **Administradores Diaz PH**.

No es una app de una sola empresa: distintas administradoras (**tenants**) operan sus propios edificios/conjuntos, residentes y datos, **aislados entre sí**, bajo su propia marca dentro de la misma base de código.

**Roles:** Superadmin de plataforma · Administradora (empresa/tenant) · Administrador de edificio · Residente/propietario.

**Funcionalidades principales:** cartelera/noticias · reservas de zonas comunes · mensajería interna · registro de visitas con reporte PDF · facturación/cuotas · PQR · votaciones/asambleas · gestión de edificios/residentes/administradores · notificaciones push por edificio.

**Distribución:** la misma base Flutter se publica en **tres canales** — Google Play, App Store y versión web. **No hay pagos dentro de la app por ahora** (se retoma más adelante; ver §6).

**Etapa:** producto en diseño / v2 pre-producción. Base reutilizable para muchas administradoras, no solo el cliente piloto.

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

## 3. Arquitectura multi-tenant

**Decisión clave:** un solo proyecto Supabase, **no** uno por administradora. Aislamiento a **nivel de fila** (RLS).

- Cada administradora = registro en `tenants` (marca, contacto, colores).
- Tablas de negocio con `tenant_id` (directo o vía `building_id`).
- **RLS** por `tenant_id` y rol.
- **Marca dinámica:** un solo build Flutter; config de marca desde Supabase al login.

**Alternativa futura:** flavors white-label por cliente enterprise — no es la base por defecto.

## 4. Roles y permisos

| Rol | Alcance | Acciones típicas |
|---|---|---|
| Superadmin plataforma | Global | Crea administradoras, soporte, métricas |
| Administradora (tenant) | Su tenant | Edificios, residentes, cobros (estado), comunicaciones, marca |
| Administrador de edificio | Edificios asignados | Visitas, PQR, noticias, reservas |
| Residente / propietario | Su unidad y edificio | Cartelera, reservas, ve facturas, PQR, votaciones, visitas |

`profiles`: `tenant_id`, `role`. Relaciones: `building_admins`, `resident_units`.

## 5. Entidades principales

Detalle: [`database/schema.sql`](database/schema.sql), [`database/er-diagram.md`](database/er-diagram.md).

`tenants` · `buildings` · `units` · `profiles` · `building_admins` · `resident_units` · `invoices` · `payments` · `pqr` · `news` · `common_areas` · `reservations` · `visits` · `messages` · `polls` · `poll_options` · `votes` · `notifications_log`

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
