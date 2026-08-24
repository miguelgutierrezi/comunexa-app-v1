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

## Base de datos

| Documento | Contenido |
|---|---|
| [database/er-diagram.md](database/er-diagram.md) | ER |
| [database/schema.sql](database/schema.sql) | SQL |
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
3. **GHA**: web en `main`; móvil en tags → canales de prueba  
4. Pagos **pausados**; esquema listo  
5. Piloto: Diaz PH  
