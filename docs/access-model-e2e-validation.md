# Validación E2E — cierre modelo de acceso (Fases A–E)

Checklist para validar manualmente el flujo **Auth + membresías + router** contra Supabase local o remoto.

Relacionado: [`database/access-model.md`](database/access-model.md) · [`setup.md`](setup.md) · [`../supabase/scripts/006_e2e_access_seed.sql`](../supabase/scripts/006_e2e_access_seed.sql)

## Estado del cierre (Fases A–E)

| Fase | Entregable | Estado |
|------|------------|--------|
| **A** | SQL 005: FKs compuestas + RLS SELECT estricto + pgTAP | Hecho |
| **B** | `AccessContextRepository` (Supabase/Fake) + `SessionNotifier` sin mocks productivos | Hecho |
| **C** | `authenticatedWithoutAccess` + `/no-access` | Hecho |
| **D** | `onAuthStateChange` + `/reset-password` + deep link recovery | Hecho |
| **E** | Seed E2E + esta guía + quality gate | Hecho |

## 1. Preparar entorno local

```bash
cd comunexa-app-v1
supabase start
./scripts/e2e-local-setup.sh   # db reset + seed + pgTAP 26/26
```

O manualmente:

```bash
supabase db reset
docker exec -i supabase_db_comunexa-app-v1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
  < supabase/scripts/006_e2e_access_seed.sql
supabase test db
```

(Requiere Docker + Supabase local. Con `psql` en el host, usa la `DB_URL` de `supabase status`.)

Copiar credenciales en `.env`:

```bash
supabase status   # API URL + anon key
```

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=<anon key>
# Opcional recovery web local:
AUTH_REDIRECT_URL=http://localhost:3000/reset-password
```

En Supabase Dashboard (local o remoto) → Authentication → URL Configuration, añadir la redirect de recovery.

## 2. Quality gate (obligatorio antes de cerrar)

```bash
flutter analyze
flutter test                    # 97 tests (Fake repos; sin Supabase)
flutter build web --release
supabase test db                # 26/26 pgTAP
./scripts/e2e-api-smoke.sh      # login/membresías seed E2E (Supabase local)
```

## 3. Usuarios de prueba

### Con Supabase + seed E2E

| Email | Password | Resultado esperado |
|-------|----------|------------------|
| `e2e-single@comunexa.local` | `ComunexaE2E!1` | Splash → `/home` (Torres del Parque) |
| `e2e-multi@comunexa.local` | `ComunexaE2E!1` | Splash → `/select-context` (4 propiedades) |
| `e2e-noaccess@comunexa.local` | `ComunexaE2E!1` | Splash → `/no-access` |

### Sin Supabase (`.env` vacío) — demos UI

| Email | Password | Resultado |
|-------|----------|-----------|
| `demo:single@test.com` | cualquiera | `/home` (FakeAccessContextRepository) |
| `demo:multi@test.com` | cualquiera | `/select-context` |
| `demo:noaccess@test.com` | cualquiera | `/no-access` |
| `demo:recovery@test.com` | cualquiera | `/reset-password` |

## 4. Matriz de validación manual

Marca cada ítem tras probarlo en **web** (`flutter run -d chrome` o build release).

**Última pasada API smoke (2026-08-25):** `./scripts/e2e-api-smoke.sh` → **OVERALL PASS** (login/membresías/full_name/recover/logout). UI Figma demos: widget tests login/home. Ítems marcados abajo reflejan esa pasada; los de UI Chrome pura quedan abiertos para confirmación visual.

### Auth básico

- [x] Login con credenciales inválidas → banner de error (sin navegar) — API 400 + widget `demo:invalid`
- [x] Login `e2e-single@…` → home con nombre de propiedad correcto — 1 membresía `Torres del Parque` + `full_name`
- [x] Cerrar sesión desde shell/selector → `/login` — Auth logout 204 (+ widget signOut)
- [x] Recargar app con sesión activa → splash → home (restore JWT) — `GET /auth/v1/user` con JWT válido

### Multirrol

- [x] Login `e2e-multi@…` → selector con 4 propiedades — API 4 membresías (Torres, Atalia, Serena, Omega)
- [ ] Elegir propiedad → `/home` con switcher operativo — *UI Chrome*
- [ ] Cambiar propiedad desde header/sidebar → contexto actualizado — *UI Chrome* (cubierto en widget tests home)
- [ ] `lastContextId` en SharedPreferences: re-login → entra directo a última propiedad — *UI Chrome* (cubierto en session tests)

### Sin acceso

- [x] Login `e2e-noaccess@…` → `/no-access` con mensaje y CTA cerrar sesión — 0 membresías + widget `demo:noaccess`
- [ ] Intentar `/home` manualmente → redirect a `/no-access` — *UI Chrome* (cubierto en router tests)

### Recuperación de contraseña

- [x] Login → “¿Olvidaste tu contraseña?” → snackbar/diálogo de confirmación — `POST /auth/v1/recover` 200 + widget
- [ ] (Remoto) Correo con link → abre `/reset-password`
- [x] (Local) `demo:recovery@test.com` → formulario nueva contraseña — widget test
- [ ] Guardar contraseña → destino post-login según membresías — *UI Chrome*
- [ ] `onAuthStateChange`: logout en otra pestaña → sesión local limpia — *UI Chrome* (cubierto en auth_state_sync tests)

### Router / deep links

- [ ] `/news/new` con sesión activa → formulario añadir noticia — *UI Chrome* (widget add_news)
- [ ] Sin sesión → redirect `/login` — *UI Chrome* (router tests)
- [ ] Recovery pendiente → solo `/reset-password` accesible — *UI Chrome* (router tests)

## 5. Supabase remoto (pre-prod)

1. `supabase db push` (migraciones 001–005).
2. Crear usuarios en Authentication (email confirmado).
3. Ejecutar solo la parte de inserts de org/property/memberships del seed, sustituyendo `profile_id` por los UUID de `auth.users` creados.
4. Configurar `AUTH_REDIRECT_URL` al dominio Firebase Hosting + `/reset-password`.
5. Repetir matriz §4 con usuarios reales.

## 6. Troubleshooting

| Síntoma | Causa probable | Acción |
|---------|----------------|--------|
| Login OK pero siempre `/no-access` | Sin membresías `active` o RLS bloquea SELECT | Verificar filas en `property_memberships`; revisar `profile_id` |
| Lista de contextos vacía con membresías en DB | Org/property `active = false` | Activar filas o revisar joins en repo |
| Recovery no abre app | Redirect URL no registrada en Supabase | Añadir URL exacta en Auth settings |
| Login E2E 500 `confirmation_token` / schema | Seed incompleto (`auth.identities` o tokens NULL) | Re-ejecutar `./scripts/e2e-local-setup.sh` (seed 006 actualizado) |
| Tests Flutter OK pero E2E falla | `.env` apunta a proyecto sin seed | Ejecutar seed o usar usuarios E2E |
| pgTAP falla tras seed manual | No relacionado si no modificaste migrations | `supabase db reset` + seed + `supabase test db` |

## 7. Pendiente post-E (fuera de este cierre)

- Cutover datos legacy (`tenants`/`buildings` → org/property).
- Seed producción Diaz PH.
- OAuth Google/Apple.
- Repositorios de dominio (noticias, visitas, …).
- RLS en tablas de negocio.
