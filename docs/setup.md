# Guía de setup — Comunexa

**Un solo ambiente** (pre-producción). Brief: [`technical-brief.md`](technical-brief.md).

## Prerrequisitos

- Flutter SDK (stable)
- Node.js 18+ / Supabase CLI
- Cuenta [Supabase](https://supabase.com)
- Cuenta Firebase (**FCM + Hosting**)
- GitHub (Actions) cuando uses CI
- Apple / Play — solo al activar móvil

## 1. Flutter

```bash
cd comunexa-app-v1
flutter pub get
flutter doctor
```

## 2. Supabase

```bash
brew install supabase/tap/supabase
supabase login
```

1. Crear **un** proyecto (ej. `comunexa`).
2. Enlazar y migrar:

```bash
supabase link --project-ref <PROJECT_REF>
supabase db push
```

### Tests RLS locales (Docker requerido)

```bash
supabase start
supabase test db   # pgTAP en supabase/tests/*.test.sql
supabase stop
```

Detalle: [`database/access-model.md`](database/access-model.md) · workflow [`.github/workflows/rls.yml`](../.github/workflows/rls.yml).

## 3. Variables Flutter

```bash
cp .env.example .env
# editar .env con SUPABASE_URL, SUPABASE_ANON_KEY, etc.
```

La app carga `.env` sola al arrancar (`bootstrap` → `Env.load()` + `ComunexaSupabase.initialize()`).

```bash
flutter run -d chrome
```

No hace falta `--dart-define-from-file` en local.  
`.env` está en `.gitignore` y también declarado como asset en `pubspec.yaml`.

Uso en código: `Env.supabaseUrl`, `Env.supabaseAnonKey`, `Env.isConfigured`.  
Cliente: `supabaseClientProvider` / `ComunexaSupabase.client` solo desde capas `data/` (no en `presentation`). Sin URL/key la UI mock sigue viva.

## 4. Auth

**Proveedor:** Supabase Auth (no Firebase Auth). Firebase = FCM + Hosting.

Dashboard → Authentication:
1. Habilitar **Email** (password).
2. Redirect URL = dominio Hosting (y deep links móviles cuando existan).
3. Opcional después: Google / Apple vía OAuth (mismos providers en Dashboard; UI ya muestra botones como “próximamente”).

`handle_new_user` crea `profiles`. La app usa `AuthRepository` → `signInWithPassword` / `signOut` / `sendPasswordResetEmail` / restore de sesión JWT.

## 5. Storage

Buckets: `tenant-assets`, `property-assets`, `building-docs`, `pqr-attachments` (ver [security.md](security.md)). `property-assets` se crea junto con la migración de propiedades/membresías, no antes de forma aislada.

## 6. Firebase (FCM + Hosting)

1. **Un** proyecto Firebase (ej. `comunexa`) — no el de Diaz PH v2.
2. Activar Hosting (+ FCM cuando toque push).
3. Sin Firestore / Auth de Firebase.

```bash
firebase login
firebase use --add
flutter build web --release
firebase deploy --only hosting
```

Config: [`../firebase.json`](../firebase.json). Detalle: [`../firebase/README.md`](../firebase/README.md).

## 7. Edge Functions

```bash
supabase secrets set FCM_SERVER_KEY=...
# payment-webhook = stub 501
```

## 8. Ejecutar

```bash
flutter run -d chrome
flutter run --dart-define-from-file=.env
```

## 9. CI / tiendas

Ver [`ci-cd.md`](ci-cd.md). Android/iOS off hasta `ENABLE_*_CI=true`.

## 10. Tenant piloto

En el único proyecto: insert `tenants` (Diaz PH), buildings, units, admin.

## Más adelante

Cuando haya producción real: clonar a proyectos `comunexa-prod` (Supabase + Firebase) y dejar este como development. **No hace falta ahora.**

## Checklist

- [ ] Flutter OK
- [ ] Un Supabase + migraciones
- [ ] Un Firebase + Hosting
- [ ] `.env` listo
- [ ] `flutter build web` + deploy (opcional)
