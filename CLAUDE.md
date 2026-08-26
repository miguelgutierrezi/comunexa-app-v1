# Comunexa — Claude Code

**Leer primero:** [`AGENTS.md`](AGENTS.md) · [`docs/technical-brief.md`](docs/technical-brief.md)

Stack: Flutter + **Supabase (RLS)** + **FCM** + **Firebase Hosting** + **GitHub Actions**.  
Pagos in-app pausados (stub `payment-webhook`). No Firestore.

**Estado (2026-08-25):** fundamentos + UI login + **splash todos breakpoints L+D** + **home shell mock** + **añadir noticia** (móvil / tablet port+land / desktop · light+dark). Auth Supabase / go_router pendientes. Ver [`docs/roadmap.md`](docs/roadmap.md).

Modelo objetivo antes de Auth: organización → propiedad → unidad, con membresías contextuales (`organization_admin`, `property_manager`, `property_staff`, `member`) y `platform_superadmin` global. El SQL actual `profiles.role`/`buildings` es transitorio; hoteles son extensibilidad futura, no alcance MVP.

Branding objetivo: propiedad → organización → Comunexa, con `co_branded` como modo MVP y `white_label` reservado para enterprise. La personalización no reemplaza el sistema de diseño ni la accesibilidad.

Comercial/onboarding: suscripción B2B pagada por organización o propiedad, manual durante el piloto y separada de pagos de residentes; el usuario final no paga acceso. Miembros entran por invitación privada o solicitud aprobada. Multirrol selecciona contexto solo si hay varios; plataforma es contexto separado y auditado. Ver `docs/subscriptions-and-onboarding.md`.

Vigilancia es preset `security_guard` de `property_staff`, con control de acceso append-only. Imágenes de usuario: PNG/JPEG/WebP procesados en backend; SVG no en MVP. Nombre/icono nativos de cliente requieren white-label enterprise; la app compartida conserva Comunexa. Ver `docs/access-control-and-media.md`.

## Quality gate (mandatorio antes de cerrar)

```bash
flutter analyze && flutter test && flutter build web --release
```

1. Añadir/actualizar **tests** para lo que se implementó.  
2. Todo en verde.  
3. Si hay impacto de producto/arquitectura/estado → actualizar `docs/` **y** las 3 superficies de agentes:
   - `AGENTS.md` + este `CLAUDE.md`
   - `.cursor/rules/`
   - `.github/copilot-instructions.md`

Regla completa: [`AGENTS.md` § Quality gate](AGENTS.md) · [`.cursor/rules/quality-gate.mdc`](.cursor/rules/quality-gate.mdc).

| Doc | Uso |
|---|---|
| [`docs/setup.md`](docs/setup.md) | Setup local / tiendas |
| [`docs/ci-cd.md`](docs/ci-cd.md) | GHA y secretos |
| [`docs/database/`](docs/database/) | SQL + RLS |
| [`docs/flutter-structure.md`](docs/flutter-structure.md) | Árbol `lib/` real vs objetivo |
| [`.cursor/rules/`](.cursor/rules/) | Reglas Cursor |
| [`.github/copilot-instructions.md`](.github/copilot-instructions.md) | GitHub Copilot |

Restricciones duras: no secretos en git · no desactivar RLS · no completar pasarela de pagos sin pedirlo · responder en español · no cerrar sin quality gate + docs/agentes.
