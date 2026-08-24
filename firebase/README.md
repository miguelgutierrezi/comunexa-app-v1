# Firebase en Comunexa — FCM + Hosting

Comunexa **no usa Firebase** como backend de datos. Auth, Postgres y archivos están en **Supabase**.

Firebase se usa para:

1. **Cloud Messaging (FCM)** — push notifications  
2. **Hosting** — deploy del build estático de Flutter Web  

## Qué configurar

| Servicio Firebase | ¿Usar? |
|---|---|
| Cloud Messaging (FCM) | **Sí** |
| Hosting | **Sí** (Flutter Web) |
| Authentication | No — Supabase Auth |
| Firestore | No — Postgres |
| Storage | No — Supabase Storage |

## Por qué Hosting y no Vercel

- El plan Hobby de Vercel **prohíbe uso comercial** en sus términos.
- Firebase Hosting free: ~10 GB storage + ~360 MB/día transferencia — suficiente al inicio.
- Flutter Web es estático; no necesita edge compute de Vercel.
- Misma cuenta Firebase que FCM.

## Proyectos

**Ahora (pre-prod):** un solo proyecto Firebase, ej. `comunexa` — FCM + Hosting.

No reutilizar el del prototipo `administradores-diaz-ph-v2`.

**Futuro:** cuando exista producción real, crear `comunexa-prod` y dejar este como development.

## Archivos locales (gitignored)

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Config de Hosting versionada: [`firebase.json`](firebase.json) en la raíz del repo (apunta a `build/web`).

## Flutter

- Push: `firebase_core` + `firebase_messaging`
- Token → `profiles.fcm_token` (Supabase)
- Envío: Edge Function `send-push`

CI: [`.github/workflows/web.yml`](../.github/workflows/web.yml).  
Deploy automático: secrets `FIREBASE_PROJECT_ID` + `FIREBASE_SERVICE_ACCOUNT` — ver [`docs/ci-cd.md`](../docs/ci-cd.md).

## Referencias

- [docs/setup.md](../docs/setup.md)
- [docs/supabase-functions.md](../docs/supabase-functions.md)
