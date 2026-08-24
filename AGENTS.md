# AGENTS.md — Guía para agentes de IA

Instrucciones al trabajar en **Comunexa** (`comunexa-app-v1`).

## Stack

| Capa | Tecnología |
|---|---|
| Cliente | Flutter + Riverpod + go_router |
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

## Orden de lectura

1. [`docs/technical-brief.md`](docs/technical-brief.md)
2. Este archivo
3. [`docs/architecture.md`](docs/architecture.md)
4. Según tarea: [`docs/database/`](docs/database/), [`docs/setup.md`](docs/setup.md), [`docs/ci-cd.md`](docs/ci-cd.md), [`docs/flutter-structure.md`](docs/flutter-structure.md), [`docs/supabase-functions.md`](docs/supabase-functions.md), [`docs/security.md`](docs/security.md)

## Restricciones

### Seguridad

- No commitear `.env`, service role, keystores, `google-services.json`.
- Solo anon key en Flutter.
- No desactivar RLS.

### Multi-tenant

- No hardcodear marca Diaz PH.
- `tenant_id` en entidades; UUIDs, no nombres como FK.

### Pagos

- No implementar checkout Wompi/PayU en v1.
- No “completar” el stub `payment-webhook` sin petición explícita.

### Alcance

- UI en español; código en inglés; responder en español.

## Checklist

- [ ] ¿RLS / `tenant_id`?
- [ ] ¿Sin secretos?
- [ ] ¿Pagos no reactivados por error?
- [ ] ¿`flutter analyze` limpio?
