# Documentación para agentes de IA

## Entrada

| Archivo | Uso |
|---|---|
| [`../../AGENTS.md`](../../AGENTS.md) | Restricciones |
| [`../technical-brief.md`](../technical-brief.md) | Brief canónico |

## Por tarea

| Tarea | Doc |
|---|---|
| Arquitectura | [`../architecture.md`](../architecture.md) |
| SQL / RLS | [`../database/`](../database/) |
| Setup / tiendas | [`../setup.md`](../setup.md) |
| CI/CD | [`../ci-cd.md`](../ci-cd.md) |
| Flutter | [`../flutter-structure.md`](../flutter-structure.md) |
| Edge Functions | [`../supabase-functions.md`](../supabase-functions.md) |
| Seguridad | [`../security.md`](../security.md) |

## No hacer

- Introducir Firestore o Firebase Auth como backend.
- Implementar Wompi/PayU / completar `payment-webhook` sin pedirlo.
- Hosting en Vercel (decisión: Firebase Hosting).
- Disparar builds iOS en cada commit (solo tags `v*`).
