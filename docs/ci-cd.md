# CI/CD — GitHub Actions (Comunexa)

## Resumen

| Archivo | Disparo | Destino | Gate |
|---|---|---|---|
| [`web.yml`](../.github/workflows/web.yml) | Push a `main` | Firebase Hosting (**automático**) | Secrets Firebase |
| [`android.yml`](../.github/workflows/android.yml) | Tag `v*` | Play internal | `ENABLE_ANDROID_CI=true` |
| [`ios.yml`](../.github/workflows/ios.yml) | Tag `v*` | TestFlight | `ENABLE_IOS_CI=true` |

## Activar deploy automático web

Proyecto Firebase actual: **`comunexa-fd97d`** (un solo ambiente).

Orden del workflow `web.yml`:

1. Si hay `supabase/migrations/*.sql` → aplicar migraciones (`supabase db push`)
2. `flutter analyze` + `test` + `build web`
3. Deploy a Firebase Hosting (`live`)

Si fallan las migraciones, **no** se hace deploy (evita app nueva contra schema viejo).

### Paso 1 — Service account Firebase

Opción A (CLI):

```bash
cd comunexa-app-v1
firebase login
firebase use comunexa-fd97d
firebase init hosting:github
```

Opción B (manual): Google Cloud → proyecto `comunexa-fd97d` → Service Account con rol **Firebase Hosting Admin** → Key JSON.

### Paso 2 — Variables y Secrets en GitHub

Repo → **Settings → Secrets and variables → Actions**

**Variables** (pestaña Variables)

| Variable | Valor |
|---|---|
| `FIREBASE_PROJECT_ID` | `comunexa-fd97d` |
| `SUPABASE_PROJECT_REF` | `vqwfjmwoonntqavalqeu` |
| `SUPABASE_URL` | `https://vqwfjmwoonntqavalqeu.supabase.co` |

**Secrets** (pestaña Secrets)

| Secret | Valor |
|---|---|
| `FIREBASE_SERVICE_ACCOUNT` | JSON **completo** de la service account |
| `SUPABASE_ACCESS_TOKEN` | [Account tokens](https://supabase.com/dashboard/account/tokens) |
| `SUPABASE_DB_PASSWORD` | Password de la DB |
| `SUPABASE_ANON_KEY` | anon `public` key (opcional hasta que la app la use en build) |

El workflow usa `${{ vars.* }}` para Variables y `${{ secrets.* }}` para Secrets.

### Paso 3 — Disparar

```bash
git push origin main
```

O **Actions → Web → Run workflow**.

URL: `https://comunexa-fd97d.web.app`

### Migraciones en CI

- Hay `.sql` en `supabase/migrations/` → corre `supabase link` + `db push`.
- No hay archivos → omite el paso (solo build + Hosting).
- Migraciones ya aplicadas → `db push` no vuelve a aplicarlas (idempotente).

Nunca uses la `service_role` key en el workflow de Hosting; para migraciones basta Access Token + DB password.

### Errores frecuentes

| Error | Qué hacer |
|---|---|
| Falta `FIREBASE_SERVICE_ACCOUNT` | Pegar el JSON entero del secret |
| Falta `SUPABASE_DB_PASSWORD` | Reset password en Supabase → Database settings |
| Permission denied Hosting | Rol Firebase Hosting Admin en la SA |
| `db push` falla | Revisar SQL localmente con `supabase db push` |

## Feature flags móvil

| Variable (Settings → Variables) | Activar |
|---|---|
| `ENABLE_ANDROID_CI` | `true` cuando toque Android |
| `ENABLE_IOS_CI` | `true` cuando toque iOS |

Off por defecto. Override: Run workflow → `force_enable`.

## Secretos móvil (después)

Android: `ANDROID_KEYSTORE_*`, `PLAY_STORE_JSON_KEY`  
iOS: `MATCH_*`, `APP_STORE_CONNECT_*`, `APPLE_TEAM_ID`

## Política

1. **Web:** cada push a `main` → Hosting live.  
2. **Móvil:** flags + tag `v*` → canales de prueba.  
3. Un solo ambiente Firebase/Supabase hasta haber prod real.
