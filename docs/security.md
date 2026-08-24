# Seguridad — Comunexa

## Objetivos

1. Aislamiento multi-tenant vía **RLS**.
2. Cero secretos en git.
3. Service role solo en Edge Functions.
4. Migraciones versionadas.

## Confianza

| Componente | Confianza |
|---|---|
| Flutter + anon key | No confiable |
| RLS | Barrera principal |
| Edge Functions + service role | Confiable si valida JWT/webhook |
| FCM / Hosting | Infra; no datos de negocio |

## RLS

Fuente: [`supabase/migrations/002_rls_policies.sql`](../supabase/migrations/002_rls_policies.sql).  
Tests cross-tenant obligatorios. No desactivar RLS en prod.

## Auth / Storage

- `profiles.id` = `auth.users.id`.
- Buckets: `tenant-assets`, `building-docs`, `pqr-attachments` con políticas por tenant/edificio.

## Secretos

`.gitignore`: `.env`, keystores, `google-services.json`, etc.  
CI: ver [`ci-cd.md`](ci-cd.md).

## Pagos

Integración pausada. No almacenar credenciales de pasarela hasta reactivar. Stub `payment-webhook` no procesa cobros.

## Firebase

Solo **FCM + Hosting**. Un proyecto Firebase por ahora (pre-prod). Sin Firestore/Auth.

## Releases móviles

Keystore / certificados en GitHub Secrets. Promoción a producción en tiendas = **manual**.
