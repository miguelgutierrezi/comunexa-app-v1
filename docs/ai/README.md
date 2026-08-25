# Documentación para agentes de IA

## Entrada

| Archivo | Uso |
|---|---|
| [`../../AGENTS.md`](../../AGENTS.md) | Restricciones + estado del repo |
| [`../technical-brief.md`](../technical-brief.md) | Brief canónico |
| [`../../CLAUDE.md`](../../CLAUDE.md) | Punto de entrada Claude Code |
| [`../../.github/copilot-instructions.md`](../../.github/copilot-instructions.md) | GitHub Copilot |
| [`../../.cursor/rules/`](../../.cursor/rules/) | Reglas Cursor (siempre / por glob) |

## Por tarea

| Tarea | Doc |
|---|---|
| Estado / fases | [`../roadmap.md`](../roadmap.md) |
| Arquitectura | [`../architecture.md`](../architecture.md) |
| SQL / RLS | [`../database/`](../database/) |
| Setup / tiendas | [`../setup.md`](../setup.md) |
| CI/CD | [`../ci-cd.md`](../ci-cd.md) |
| Flutter | [`../flutter-structure.md`](../flutter-structure.md) |
| Edge Functions | [`../supabase-functions.md`](../supabase-functions.md) |
| Seguridad | [`../security.md`](../security.md) |

## Quality gate

Obligatorio al cerrar cambios de código — ver [`../../AGENTS.md`](../../AGENTS.md) y [`../../.cursor/rules/quality-gate.mdc`](../../.cursor/rules/quality-gate.mdc):

1. Tests para lo nuevo  
2. `flutter analyze` · `flutter test` · `flutter build web --release`  
3. Actualizar `docs/` **y** las 3 superficies (Cursor / Claude / Copilot) si hubo impacto  

## No hacer

- Introducir Firestore o Firebase Auth como backend.
- Implementar Wompi/PayU / completar `payment-webhook` sin pedirlo.
- Hosting en Vercel (decisión: Firebase Hosting).
- Disparar builds iOS en cada commit (solo tags `v*`).
- Tratar el login UI / bypass / home mock actuales como Auth completa (siguen siendo stub).
- Cerrar una tarea de código sin quality gate ni docs/agentes al día.
