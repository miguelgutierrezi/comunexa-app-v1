# AGENTS.md — Guía para agentes de IA

Instrucciones al trabajar en **Comunexa** (`comunexa-app-v1`).

## Stack

| Capa | Tecnología |
|---|---|
| Cliente | Flutter + Riverpod + go_router (router aún por añadir) |
| Backend | **Supabase** (Postgres, Auth, Storage, Edge Functions) |
| Aislamiento | **RLS** |
| Push | **FCM** |
| Hosting web | **Firebase Hosting** |
| CI/CD | **GitHub Actions** (web en `main`; android/ios por tag `v*` + flags) |
| Ambientes | **Uno solo** (pre-prod). Separar prod cuando haya usuarios reales |
| Pagos | **Pausados** — stub `payment-webhook`; tablas `invoices`/`payments` sí existen |

- No Firestore / Firebase Auth.
- Greenfield: no copiar código de `administradores-diaz-ph-v2`.
- Piloto: Administradores Diaz PH SAS.

## Estado del repo (2026-08-25)

| Hecho | Pendiente inmediato |
|---|---|
| Schema + RLS inicial en `supabase/migrations/` | Migrar membresías contextuales antes de Auth; luego `db push` + seed Diaz PH |
| Bootstrap, `Env`, tema light/dark, brand assets | `supabase_flutter` + client tipado |
| Splash → Login UI responsive (stub auth; Apple solo iOS/macOS) · SessionProvider persistido | go_router + Auth real Supabase |
| Bypass login → **Home shell mock** (móvil / tablet / desktop · light+dark) | Selector tablet/desktop; home por rol + Auth real |
| Workflows GHA + remote GitHub | Secrets/variables GHA + CI verde |
| Stub `payment-webhook` | Features de negocio reales (Fase 4) |

Detalle: [`docs/roadmap.md`](docs/roadmap.md) · mapa `lib/`: [`docs/flutter-structure.md`](docs/flutter-structure.md).

## Orden de lectura

1. [`docs/technical-brief.md`](docs/technical-brief.md)
2. Este archivo
3. [`docs/architecture.md`](docs/architecture.md)
4. Según tarea: [`docs/database/`](docs/database/), [`docs/setup.md`](docs/setup.md), [`docs/ci-cd.md`](docs/ci-cd.md), [`docs/flutter-structure.md`](docs/flutter-structure.md), [`docs/supabase-functions.md`](docs/supabase-functions.md), [`docs/security.md`](docs/security.md)

## Mapa rápido `lib/`

| Path | Qué es |
|---|---|
| `main.dart` / `app.dart` | Entry + `MaterialApp` (sin go_router todavía) |
| `core/config/env.dart` | `.env` / dart-define |
| `core/theme/` | `AppTheme` + `BrandAssets` (marca producto) |
| `features/splash/` | Splash todos breakpoints light+dark |
| `features/auth/` | Login + selector contexto mock (`demo:multi`) + post-login stub |
| `features/home/` | Shell + feed + añadir noticia (móvil/tablet/desktop) + dashboards |
| `services/` | Vacío; FCM etc. llegan después |

## Restricciones

### Seguridad

- No commitear `.env`, service role, keystores, `google-services.json`.
- Solo anon key en Flutter.
- No desactivar RLS.

### Multi-tenant

- No hardcodear marca Diaz PH.
- `tenant_id` en entidades; UUIDs, no nombres como FK.
- Dominio objetivo: organización → propiedad → unidad. `tenant`/`building` son nombres SQL actuales hasta migración explícita.
- No añadir roles operativos a `profiles.role`: usar membresías de organización/propiedad. Roles objetivo: `platform_superadmin`, `organization_admin`, `property_manager`, `property_staff`, `member`.
- Hoteles son extensibilidad futura, no alcance funcional del MVP PH.
- Branding de producto (`BrandAssets`) ≠ branding de tenant (futuro desde `tenants`).
- **Assets:** reutilizar logos/símbolo/iconos de `BrandAssets` / `assets/branding/` antes de exportar de Figma; no duplicar el mismo mark.
- Branding efectivo: propiedad → organización → Comunexa. `co_branded` es el modo MVP recomendado; `white_label` sin firma Comunexa es enterprise futuro.
- Solo `organization_admin` y `property_manager` modifican branding de propiedad; validar contraste y assets. No permitir que la personalización reemplace estructura, componentes o accesibilidad.
- Imágenes de usuario MVP: PNG/JPEG/WebP validados y re-encodeados en backend; quitar metadatos. No aceptar SVG de usuario ni publicar cargas sin procesar.
- Nombre/icono nativos personalizados requieren build white-label enterprise; la app compartida conserva Comunexa. PWA dedicada puede usar manifest propio.
- Vigilancia = preset `security_guard` de `property_staff`, con permisos mínimos para autorizaciones, visitas, vehículos y eventos; no crear otro rol global.

### Pagos

- No implementar checkout Wompi/PayU en v1.
- No “completar” el stub `payment-webhook` sin petición explícita.
- Distinguir pagos de residentes (pausados) de la suscripción B2B de Comunexa. Puede pagar organización o propiedad y cubrir una o varias propiedades; el usuario final no paga acceso. Piloto: factura y activación manual; no reutilizar `invoices`/`payments` operativos.

### Suscripción y onboarding

- Modelo objetivo: cargo base por organización + unidades activas + complementos; planes conceptuales `essential`, `management`, `enterprise`.
- Acceso de miembros: invitación privada o solicitud mediante código público. El código público nunca otorga acceso.
- Multirrol: un contexto entra directo; varios muestran selector de propiedad/organización/función. Plataforma es contexto separado; accesos de soporte deben auditarse, sin suplantación silenciosa.
- Aprobar solicitudes solo con permisos contextuales; tokens privados expirables, revocables, de uso limitado y almacenados como hash.
- Fuente: [`docs/subscriptions-and-onboarding.md`](docs/subscriptions-and-onboarding.md).

### Alcance

- UI en español; código en inglés; **responder al usuario en español**.
- Cambios mínimos alineados a la tarea; no saltar a Fase 4 sin pedirlo.
- Home/login son **UI mock** hasta Auth real: no tratar bypass como sesión.

## Quality gate (mandatorio)

Ningún cambio de código se cierra sin esto. Detalle también en [`.cursor/rules/quality-gate.mdc`](.cursor/rules/quality-gate.mdc) y [`docs/conventions.md`](docs/conventions.md).

### 1. Comandos (orden)

```bash
flutter analyze
flutter test
flutter build web --release
```

Los tres deben pasar (mismo criterio que `web.yml`). Solo-docs: no exige build.

### 2. Tests para lo nuevo

- Feature/pantalla/lógica nueva → tests unit/widget **en el mismo cambio**.
- Fix → test de regresión cuando sea razonable.
- Preferir `test/features/<feature>/` para smoke de pantallas (login, home).

### 3. Documentación + 3 agentes

Si hay impacto en comportamiento, schema, fases, `lib/` o convenciones, actualizar **en el mismo cambio**:

| Superficie | Archivos |
|---|---|
| Docs producto/técnicas | `docs/` (p. ej. `roadmap`, `flutter-structure`, `architecture`) |
| Cursor | `.cursor/rules/` (`project-core` + reglas tocadas; `quality-gate` si cambia el gate) |
| Claude / genérico | `AGENTS.md`, `CLAUDE.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |

Las tres superficies de agentes deben quedar **alineadas** (mismo estado y restricciones).

## Checklist

- [ ] ¿RLS / `tenant_id`?
- [ ] ¿Sin secretos?
- [ ] ¿Pagos no reactivados por error?
- [ ] ¿Tests nuevos/actualizados para lo añadido?
- [ ] ¿`flutter analyze` + `flutter test` + `flutter build web --release` OK?
- [ ] ¿Docs + reglas Cursor / Claude / Copilot al día?
