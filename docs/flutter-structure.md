# Estructura Flutter — Comunexa

Arquitectura **por feature** con capas `data` / `domain` / `presentation` dentro de cada módulo.

## Árbol objetivo

```
lib/
├── main.dart
├── app.dart                          # MaterialApp.router + ProviderScope
├── bootstrap.dart                    # init Supabase, env, FCM
│
├── core/
│   ├── config/
│   │   └── env.dart                  # SUPABASE_URL, keys por flavor
│   ├── routing/
│   │   ├── app_router.dart           # go_router
│   │   └── routes.dart
│   ├── session/
│   │   ├── session_state.dart
│   │   └── session_provider.dart     # tenant activo, edificio activo, perfil
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── tenant_theme.dart         # colores desde tenants
│   ├── errors/
│   │   └── app_exception.dart
│   └── supabase/
│       └── supabase_client.dart      # singleton tipado
│
├── shared/
│   ├── widgets/                      # botones, inputs, loaders
│   ├── extensions/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── profile_dto.dart
│   │   ├── domain/
│   │   │   └── profile.dart          # freezed
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── auth_provider.dart
│   │
│   ├── tenant/
│   │   ├── data/tenant_repository.dart
│   │   ├── domain/tenant_config.dart
│   │   └── presentation/
│   │
│   ├── buildings/
│   ├── news/
│   ├── reservations/
│   ├── messaging/
│   ├── visits/
│   ├── billing/
│   ├── pqr/
│   ├── voting/
│   └── admin/                        # gestión interna tenant/edificios
│
└── services/
    ├── fcm_service.dart              # solo Firebase Messaging
    └── platform_service.dart
```

## Estado actual vs objetivo

Actualizado **2026-08-25**.

### Árbol real hoy

```
lib/
├── main.dart                 # Env.load + ProviderScope
├── app.dart                  # MaterialApp (aún sin go_router)
├── core/
│   ├── config/env.dart
│   ├── errors/app_exception.dart
│   └── theme/
│       ├── app_theme.dart    # light/dark + tipografía
│       └── brand_assets.dart
├── features/
│   ├── splash/presentation/splash_screen.dart
│   └── auth/presentation/login_screen.dart   # UI completa, auth stub
└── services/                 # vacío (.gitkeep)
```

| Hoy | Objetivo |
|---|---|
| Splash → Login vía `Navigator` | `go_router` + redirect por sesión |
| Login UI responsive + tests | Conectar Supabase Auth + providers |
| Apple Sign-In solo iOS/macOS (override en tests) | Cablear OAuth real por plataforma |
| `ProviderScope` sin providers de dominio | SessionProvider + auth_provider |
| Sin `go_router` / `supabase_flutter` | Añadir en Fase 2 |
| Sin freezed | Generar modelos al conectar BD |
| Tema fijo Comunexa | `tenant_theme` desde `tenants` |

## Capas por feature

```
features/<name>/
├── data/           # Repositorios, DTOs, mapeo Supabase → domain
├── domain/         # Entidades freezed, reglas puras
└── presentation/   # Screens, widgets, providers Riverpod
```

**Reglas:**

- `presentation` → solo providers y domain; **nunca** `Supabase.instance.client` directo.
- `data` → encapsula queries `.from('table').select()` y manejo de errores Postgrest.
- `domain` → sin imports de Flutter ni Supabase.

## Navegación (go_router)

Rutas declarativas con deep links para push:

| Ruta | Pantalla | Deep link ejemplo |
|---|---|---|
| `/login` | Login | — |
| `/home` | Shell principal | — |
| `/news/:id` | Detalle noticia | `comunexa://news/{id}` |
| `/pqr/:id` | Detalle PQR | `comunexa://pqr/{id}` |
| `/invoices/:id` | Factura | `comunexa://invoices/{id}` |

Redirect guard: si no hay sesión → `/login`; si hay sesión → cargar tenant theme.

## Dependencias previstas (`pubspec.yaml`)

```yaml
dependencies:
  flutter_riverpod: ...
  go_router: ...
  supabase_flutter: ...
  freezed_annotation: ...
  json_annotation: ...
  firebase_messaging: ...   # solo FCM

dev_dependencies:
  build_runner: ...
  freezed: ...
  json_serializable: ...
```

## Tests

```
test/
├── core/
├── features/
│   └── news/
│       ├── data/news_repository_test.dart
│       └── presentation/news_list_test.dart
└── widget_test.dart
```

Mock de Supabase con interfaces de repositorio; no hit real a BD en unit tests.
