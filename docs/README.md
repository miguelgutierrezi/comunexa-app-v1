# Documentación — Comunexa

## Brief canónico

**[technical-brief.md](technical-brief.md)**

## Implementación

| Documento | Contenido |
|---|---|
| [architecture.md](architecture.md) | Sistema y flujos |
| [setup.md](setup.md) | Setup (Supabase, Firebase, tiendas, CI) |
| [ci-cd.md](ci-cd.md) | GitHub Actions y secretos |
| [flutter-structure.md](flutter-structure.md) | Estructura `lib/` |
| [supabase-functions.md](supabase-functions.md) | Edge Functions (pagos = stub) |
| [conventions.md](conventions.md) | Código y commits |
| [security.md](security.md) | RLS y secretos |
| [roadmap.md](roadmap.md) | Fases |
| [subscriptions-and-onboarding.md](subscriptions-and-onboarding.md) | Planes, suscripción B2B, invitaciones y solicitudes de acceso |
| [access-control-and-media.md](access-control-and-media.md) | Vigilancia, visitas, vehículos y validación de imágenes |

## Base de datos

| Documento | Contenido |
|---|---|
| [database/er-diagram.md](database/er-diagram.md) | ER |
| [database/access-model.md](database/access-model.md) | Modelo acceso 003 (org/property/memberships) |
| [database/schema.sql](database/schema.sql) | SQL legacy 001 (referencia) |
| [database/rls-policies.md](database/rls-policies.md) | RLS |
| [../supabase/migrations/](../supabase/migrations/) | Fuente canónica |

## Producto / agentes

| Documento | Contenido |
|---|---|
| [product-vision.md](product-vision.md) | Visión |
| [ai/README.md](ai/README.md) | Índice agentes |

## Resumen

1. Un Supabase · muchos tenants · **RLS**  
2. Un Flutter · Play + App Store + **Firebase Hosting**  
3. **Un ambiente** backend por ahora (pre-prod)  
4. **GHA**: web en `main`; móvil en tags → canales de prueba  
5. Pagos de residentes **pausados**; suscripción B2B del piloto por factura/activación manual
6. Piloto: Diaz PH  

## Estado del código (2026-08-25)

| Área | Estado |
|---|---|
| Docs + migraciones SQL/RLS + stub pagos | Listo |
| CI workflows en repo | Listo (secrets GHA pendientes de verificar) |
| Flutter: tema, splash, **login UI** responsive | Listo (auth real pendiente; Apple solo iOS/macOS) |
| Flutter: **home shell mock** (móvil / tablet / desktop · light+dark) | Listo (datos mock) |
| `supabase_flutter` / go_router / SessionProvider | Pendiente (Fase 2) |
| Features de negocio reales (noticias API, visitas, …) | Pendiente (Fase 4; UI mock noticias en home) |

Ver [roadmap.md](roadmap.md).
