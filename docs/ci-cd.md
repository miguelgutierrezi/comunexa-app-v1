# CI/CD — GitHub Actions (Comunexa)

Tres workflows independientes. Detalle: [`technical-brief.md`](technical-brief.md) §7.

## Resumen

| Archivo | Runner | Disparo | Destino | Gate |
|---|---|---|---|---|
| [`web.yml`](../.github/workflows/web.yml) | `ubuntu-latest` | Push a `main` | Firebase Hosting | Siempre activo |
| [`android.yml`](../.github/workflows/android.yml) | `ubuntu-latest` | Tag `v*` | Play internal | `ENABLE_ANDROID_CI=true` |
| [`ios.yml`](../.github/workflows/ios.yml) | `macos-latest` | Tag `v*` | TestFlight | `ENABLE_IOS_CI=true` |

## Feature flags (variables de repositorio)

Hasta tener builds estables para tiendas, **Android e iOS van deshabilitados por defecto**.

En GitHub → **Settings → Secrets and variables → Actions → Variables**:

| Variable | Valor para activar | Efecto |
|---|---|---|
| `ENABLE_ANDROID_CI` | `true` | Ejecuta build AAB (y más adelante supply a Play) |
| `ENABLE_IOS_CI` | `true` | Ejecuta build en macOS / TestFlight |

Cualquier otro valor (o variable ausente) = **no se construye**. El workflow puede dispararse por un tag, pero solo corre un job `gate` barato en `ubuntu-latest` y sale con un aviso — **no gasta minutos macOS**.

### Override manual

En **Actions → Android / iOS → Run workflow**, marcar `force_enable` para probar un build sin cambiar la variable del repo.

### Cuándo activarlos

1. Keystore / certificados listos y secrets configurados.
2. App estable en web (o local) para el piloto.
3. Cuentas Play / App Store Connect listas.
4. Entonces: `ENABLE_ANDROID_CI=true` y/o `ENABLE_IOS_CI=true`.

Web no usa este gate: el deploy a Hosting sigue en cada push a `main` (bajo riesgo, fácil de revertir).

## Secretos de GitHub

### Web / Firebase Hosting

| Secret | Uso |
|---|---|
| `FIREBASE_SERVICE_ACCOUNT_COMUNEXA_PROD` | Service account para Hosting deploy |
| `FIREBASE_PROJECT_ID` | Project ID |

### Android (solo si `ENABLE_ANDROID_CI=true`)

| Secret | Uso |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Keystore en base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Password keystore |
| `ANDROID_KEY_ALIAS` | Alias |
| `ANDROID_KEY_PASSWORD` | Password key |
| `PLAY_STORE_JSON_KEY` | Play Developer API |

### iOS (solo si `ENABLE_IOS_CI=true`)

| Secret | Uso |
|---|---|
| `MATCH_PASSWORD` | Fastlane match |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Repo de certificados |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | `.p8` |
| `APPLE_TEAM_ID` | Team ID |

### Flutter / Supabase (opcional en build)

| Secret | Uso |
|---|---|
| `SUPABASE_URL` | URL entorno |
| `SUPABASE_ANON_KEY` | Anon key |

## Política de release

1. **Web:** merge a `main` → Hosting.
2. **Móvil:** solo con flags activos + tag `v*` → canales de prueba.
3. **Prod stores:** promoción manual en consolas.

## Costos

- macOS ≈ 10× minutos Linux → dejar `ENABLE_IOS_CI` en off hasta necesitarlo.
- Tags `v*` con flags off no consumen runners caros.

## Fastlane

```
android/fastlane/
ios/fastlane/
```

Cuando exista firma real, descomentar pasos en los YAML.
