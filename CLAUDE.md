# Comunexa — Claude Code

**Leer primero:** [`AGENTS.md`](AGENTS.md) · [`docs/technical-brief.md`](docs/technical-brief.md)

Stack: Flutter + **Supabase (RLS)** + **FCM** + **Firebase Hosting** + **GitHub Actions**.  
Pagos in-app pausados (stub `payment-webhook`). No Firestore.

**Estado (2026-08-25):** fundamentos + UI login + **home shell mock** (móvil / tablet / desktop · light+dark). Auth Supabase / go_router / features de negocio reales pendientes. Ver [`docs/roadmap.md`](docs/roadmap.md).

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
