#!/usr/bin/env bash
# Prepara Supabase local + seed E2E para validación manual del modelo de acceso.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "→ supabase db reset (migraciones 001…005 + pgTAP helpers)"
supabase db reset

echo "→ seed E2E (usuarios + membresías)"
DB_CONTAINER="$(docker ps --filter "name=supabase_db_" --format '{{.Names}}' | head -1)"
if [[ -z "$DB_CONTAINER" ]]; then
  echo "Error: contenedor supabase_db_* no encontrado. ¿Ejecutaste supabase start?" >&2
  exit 1
fi
docker exec -i "$DB_CONTAINER" psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
  < supabase/scripts/006_e2e_access_seed.sql

echo ""
echo "→ supabase test db (RLS pgTAP)"
supabase test db

echo ""
echo "Listo. Configura .env con Supabase local y ejecuta:"
echo "  SUPABASE_URL=http://127.0.0.1:54321"
echo "  SUPABASE_ANON_KEY=<anon key de supabase status>"
echo ""
echo "  flutter run -d chrome"
echo ""
echo "Usuarios seed: e2e-single|multi|noaccess @comunexa.local — password: ComunexaE2E!1"
echo "Guía: docs/access-model-e2e-validation.md"
