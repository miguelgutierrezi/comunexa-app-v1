# Guía de setup — Comunexa

Entornos: **dev** · **staging** · **prod**. Brief: [`technical-brief.md`](technical-brief.md).

## Prerrequisitos

- Flutter SDK (stable)
- Node.js 18+ / Supabase CLI / Docker (opcional, Supabase local)
- Cuenta [Supabase](https://supabase.com)
- Cuenta Firebase (**FCM + Hosting**)
- Apple Developer Program (~US$99/año) — para iOS
- Google Play Console (~US$25 único) — para Android
- Cuenta GitHub (Actions + Secrets)

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

1. Crear proyecto cloud (ej. `comunexa-dev`).
2. Enlazar y aplicar migraciones:

```bash
supabase link --project-ref <PROJECT_REF>
supabase db push
```

Local opcional: `supabase start` → `supabase db reset`.

Migraciones: [`../supabase/migrations/`](../supabase/migrations/).

## 3. Variables Flutter

```bash
cp .env.example .env
```

```env
APP_ENV=development
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

Solo **anon key** en la app. Service role → Edge Functions únicamente.

Cargar con `--dart-define-from-file=.env` o `flutter_dotenv` / `envied`.

## 4. Auth (Supabase)

Dashboard → Authentication:

- Email (password o magic link).
- Signup público off si el acceso es por invitación.
- Redirect URLs para Flutter Web (Hosting domain).

Trigger `handle_new_user` crea `profiles`. Asignar `tenant_id` + `role` post-registro (script/admin).

## 5. Storage

| Bucket | Público | Uso |
|---|---|---|
| `tenant-assets` | Sí (logo) | Branding |
| `building-docs` | No | PDFs visitas |
| `pqr-attachments` | No | Adjuntos |

Políticas alineadas con [security.md](security.md). Migración `003_storage` pendiente.

## 6. Firebase (FCM + Hosting)

1. Proyecto Firebase por entorno (ej. `comunexa-dev`) — **no** el del prototipo Diaz PH.
2. Habilitar **Cloud Messaging** y **Hosting**.
3. **No** usar Firestore / Auth de Firebase.
4. Registrar apps Android / iOS / Web; descargar configs (gitignored).
5. Hosting: [`../firebase.json`](../firebase.json) apunta a `build/web`.

```bash
npm i -g firebase-tools
firebase login
firebase use <project-id>
flutter build web --release
firebase deploy --only hosting
```

CI: [`.github/workflows/web.yml`](../.github/workflows/web.yml).

Ver [`../firebase/README.md`](../firebase/README.md).

## 7. Edge Functions

```bash
supabase secrets set FCM_SERVER_KEY=...
supabase functions deploy send-push
# payment-webhook existe como stub (501) — no configurar Wompi/PayU en v1
```

## 8. Ejecutar

```bash
flutter run --dart-define-from-file=.env
flutter run -d chrome
```

## 9. App Store Connect (iOS)

1. Apple Developer → Members / certificados (Fastlane match recomendado).
2. [App Store Connect](https://appstoreconnect.apple.com) → New App (bundle `com.comunexa.comunexa`).
3. Crear API Key (Users and Access → Keys) para CI.
4. Guardar en GitHub Secrets: `APP_STORE_CONNECT_*`, `MATCH_*`, `APPLE_TEAM_ID`.
5. Tags `v*` → workflow `ios.yml` → **TestFlight**.
6. Enviar a revisión / producción: **manual** en App Store Connect.

## 10. Google Play Console (Android)

1. Crear app en [Play Console](https://play.google.com/console).
2. Service account con acceso a Play Developer API → JSON en secret `PLAY_STORE_JSON_KEY`.
3. Keystore de upload → secrets `ANDROID_KEYSTORE_*` (nunca en git).
4. Tags `v*` → workflow `android.yml` → **pista interna/cerrada**.
5. Promover a producción: **manual** en Play Console.

## 11. CI/CD (GitHub Actions)

Ver [`ci-cd.md`](ci-cd.md).

| Workflow | Cuándo | Destino |
|---|---|---|
| `web.yml` | Push `main` | Firebase Hosting |
| `android.yml` | Tag `v*` | Play internal |
| `ios.yml` | Tag `v*` | TestFlight |

Configurar secrets antes de depender de los deploys reales.  
Android/iOS: variables `ENABLE_ANDROID_CI` / `ENABLE_IOS_CI` = `true` solo cuando toque publicar (ver [`ci-cd.md`](ci-cd.md)). Off por defecto.

## 12. Tenant piloto (Diaz PH)

1. Insert `tenants` (`slug = diaz-ph`).
2. `buildings` + `units`.
3. Admin → `profiles.role = tenant_admin`.
4. Logo en `tenant-assets`.

## Checklist

- [ ] Flutter analyze/test OK
- [ ] Supabase migraciones + RLS
- [ ] `.env` con anon key
- [ ] Firebase FCM + Hosting
- [ ] Secrets GHA (web mínimo)
- [ ] Apps creadas en Play / App Store Connect (cuando toque release)

## Referencias

- [architecture.md](architecture.md) · [ci-cd.md](ci-cd.md) · [database/er-diagram.md](database/er-diagram.md)
