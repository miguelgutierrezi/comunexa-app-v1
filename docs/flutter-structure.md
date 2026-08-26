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
│   │   └── session_provider.dart     # organización, propiedad, perfil y membresías activas
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── tenant_theme.dart         # identidad base de organización
│   │   └── effective_branding.dart   # propiedad → organización → Comunexa
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
│   ├── properties/                    # edificios/conjuntos; hotel futuro
│   ├── news/
│   ├── reservations/
│   ├── messaging/
│   ├── visits/
│   ├── access_control/                 # vigilancia, autorizaciones, vehículos y eventos
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
├── main.dart                 # bootstrap → ProviderScope
├── bootstrap.dart            # Env + session storage + Supabase
├── app.dart                  # MaterialApp.router + routerProvider
├── core/
│   ├── config/
│   │   ├── env.dart
│   │   └── auth_redirect.dart        # AUTH_REDIRECT_URL recovery
│   ├── router/
│   │   ├── app_router.dart           # go_router + redirects
│   │   └── app_routes.dart
│   ├── session/
│   │   ├── session_state.dart
│   │   ├── session_storage.dart      # Solo lastContextId (SharedPreferences)
│   │   └── session_provider.dart     # Auth stream · selectContext · recovery
│   ├── supabase/
│   │   ├── comunexa_supabase.dart
│   │   └── supabase_providers.dart
│   └── theme/
│       ├── app_theme.dart
│       └── brand_assets.dart
├── features/
│   ├── splash/presentation/splash_screen.dart
│   ├── auth/
│   │   ├── data/
│   │   │   ├── supabase_auth_repository.dart
│   │   │   ├── fake_auth_repository.dart
│   │   │   ├── supabase_access_context_repository.dart
│   │   │   ├── fake_access_context_repository.dart
│   │   │   ├── access_context_mapper.dart
│   │   │   └── mock_user_contexts.dart   # solo tests/Figma
│   │   ├── domain/
│   │   │   ├── auth_repository.dart
│   │   │   ├── access_context_repository.dart
│   │   │   └── access_context.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       ├── context_select_screen.dart
│   │       ├── no_access_screen.dart
│   │       ├── reset_password_screen.dart
│   │       └── post_login_navigation.dart
│   └── home/
│       ├── data/mock_noticias.dart           # feed mock
│       └── presentation/ …                   # shell + add_news + dashboards
└── services/                 # vacío (.gitkeep)
```

| Hoy | Objetivo |
|---|---|
| Splash → Login → Home vía `go_router` | Deep links PQR/facturas |
| Auth email/password + recovery + `onAuthStateChange` + tests (96) | OAuth Google/Apple |
| `AccessContextRepository` + sesión/contexto (Supabase/Fake) | Cutover legacy SQL |
| Home shell (breakpoints · L+D); feed **mock** | Datos reales + home por rol |
| Añadir noticia todos breakpoints light+dark | Persistencia API |
| Tablet landscape light+dark (`#35:487` / `#35:606`) | — |
| Tablet portrait light+dark (`#74:5` / `#74:117`) | — |
| Apple Sign-In solo iOS/macOS (override en tests) | Cablear OAuth real por plataforma |
| `ProviderScope` + SessionProvider (Auth + contexto + recovery) | Branding efectivo desde org/property |
| `go_router` (`/login` · `/reset-password` · `/select-context` · `/no-access` · `/home` · `/news/new`) | Rutas de dominio (`/news/:id`, …) |
| Sin freezed | Generar modelos al conectar BD |
| Tema fijo Comunexa | `tenant_theme` desde org/property |

### Breakpoints home (Figma)

| Layout | Criterio | UI |
|---|---|---|
| Mobile | resto | Header + bottom nav + feed |
| Tablet portrait | ancho ≥700 y alto > ancho | Feed columna + eventos horizontales + bottom nav light/dark (`#74:5` / `#74:117`) |
| Tablet landscape | ancho ≥900 y ancho ≥ alto | Dashboard compacto light/dark (`DashboardLayout.tabletLandscape`) |
| Desktop | ancho ≥1280 | Dashboard completo (`DashboardLayout.desktop`) |

Login usa criterios propios (p. ej. desktop ≥1280, tablet portrait ≥700 + alto>ancho, landscape ≥900 + ancho≥alto).

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

| Ruta | Pantalla | Notas |
|---|---|---|
| `/login` | Login | — |
| `/reset-password` | Nueva contraseña (recovery) | Deep link Supabase Auth |
| `/select-context` | Selector multirrol | Mobile · tablet · desktop |
| `/no-access` | Sin membresías activas | Cerrar sesión |
| `/home` | Shell principal | Property switcher en desktop |
| `/news/new` | Añadir noticia (UI mock) | Requiere contexto activo |
| `/news/:id` | Detalle noticia | *pendiente* |

Redirect guard: sin sesión → `/login`; recovery pendiente → `/reset-password`; autenticado sin membresías → `/no-access`; un contexto → `/home`; varios → `/select-context`.

Tras resolver membresías: un contexto entra directo; varios navegan a `/select-context`. En desktop (`#35:233`), el sidebar incluye **property switcher** (pill + rol) con menú para cambiar contexto sin salir del home. El selector recuerda el último contexto autorizado y persiste vía `SessionProvider`.

El tema visual consume un `EffectiveBranding` inmutable. Su resolución aplica `property branding → organization branding → BrandAssets/AppTheme`, conserva la firma Comunexa salvo `white_label` enterprise y valida contraste antes de exponer colores a widgets.

La carga de imágenes usa un servicio/repositorio; `presentation` nunca publica directamente una ruta final en Storage. Muestra preview y errores locales, pero solo activa la variante que el backend marcó como procesada.

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
├── features/
│   ├── auth/
│   │   └── login_screen_test.dart
│   └── home/
│       └── home_shell_test.dart
└── widget_test.dart          # smoke mínimo / reexport si aplica
```

Mock de Supabase con interfaces de repositorio; no hit real a BD en unit tests.
Smoke widget: login (breakpoints + demos) y home (móvil / tablet landscape / desktop).
