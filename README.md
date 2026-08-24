# Comunexa

Plataforma **SaaS white-label** multi-tenant para **administradoras de propiedad horizontal** (Colombia primero). Cliente piloto: **Administradores Diaz PH SAS**.

Misma base Flutter → **Google Play**, **App Store** y **web** (Firebase Hosting). Pagos in-app **pausados** en v1. **Un solo ambiente** backend (pre-prod).

> **Referencia UX/dominio:** [`administradores-diaz-ph-v2`](../administradores-diaz-ph-v2/) — no copiar su stack Firebase/Firestore.

## Stack

| Capa | Tecnología |
|---|---|
| App | Flutter (iOS, Android, Web) |
| Backend | **Supabase** (Postgres + Auth + Storage + Edge Functions) |
| Multi-tenant | **RLS** |
| Push | **FCM** |
| Hosting web | **Firebase Hosting** |
| CI/CD | **GitHub Actions** (`web` / `android` / `ios`) |
| Estado | Riverpod · go_router |
| Pagos | Pausado (esquema `invoices`/`payments` listo) |

## Documentación

| Documento | Contenido |
|---|---|
| [docs/technical-brief.md](docs/technical-brief.md) | **Brief canónico** |
| [docs/setup.md](docs/setup.md) | Setup completo (incl. tiendas) |
| [docs/ci-cd.md](docs/ci-cd.md) | Workflows y secretos |
| [docs/architecture.md](docs/architecture.md) | Arquitectura |
| [docs/database/](docs/database/) | SQL, RLS, ER |
| [AGENTS.md](AGENTS.md) | Guía agentes IA |

## Repo

```
comunexa-app-v1/
├── lib/                      # Flutter
├── supabase/migrations/      # SQL + RLS
├── supabase/functions/       # Edge Functions (payment-webhook = stub)
├── firebase.json             # Hosting → build/web
├── .github/workflows/        # web.yml, android.yml, ios.yml
└── docs/
```

## Getting started

```bash
flutter pub get && flutter analyze && flutter test && flutter run
```

Supabase / Firebase / CI: [docs/setup.md](docs/setup.md).

## Licencia

Proyecto privado.
