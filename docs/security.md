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
- Buckets: `tenant-assets`, `property-assets`, `building-docs`, `pqr-attachments` con políticas por organización/propiedad.
- Branding de propiedad: solo `organization_admin` y `property_manager` asignado pueden escribir; `property_staff` y `member` solo leen. Validar tipo MIME, tamaño, dimensiones y ruta, sin confiar en el cliente.
- Imágenes: allowlist PNG/JPEG/WebP, magic bytes + decodificación, límites de bytes/dimensiones/megapíxeles, re-encode, retiro de EXIF y variantes procesadas. SVG de usuarios no se admite en MVP.

## Control de acceso

- `security_guard` es un preset limitado de `property_staff`, no un rol global.
- Eventos de acceso append-only; correcciones auditadas y sin borrado por vigilancia.
- Documentos, placas, fotos y horarios requieren minimización, enmascarado, retención definida y acceso por propiedad.
- Sin reconocimiento facial en el MVP. Ver [`access-control-and-media.md`](access-control-and-media.md).

## Secretos

`.gitignore`: `.env`, keystores, `google-services.json`, etc.  
CI: ver [`ci-cd.md`](ci-cd.md).

## Pagos

Los pagos operativos de residentes están pausados. No almacenar credenciales de pasarela hasta reactivar; `payment-webhook` no procesa cobros. La suscripción B2B del piloto se registra manualmente, admite una cuenta pagadora de organización o propiedad y no reutiliza tablas ni webhook de pagos de residentes. El usuario final no paga por acceso.

## Invitaciones y solicitudes

- El código público de propiedad solo permite solicitar ingreso; nunca crea acceso ni revela unidades o miembros.
- Tokens privados aleatorios, expirables, revocables y de uso limitado; guardar hash, no token en claro.
- Aprobar mediante RLS/función confiable solo por `organization_admin`, `property_manager` o `property_staff` con `manage_members`.
- Auditar creador, revisor, timestamps, cambios de estado y rechazo; aplicar rate limiting y rotación ante abuso.
- Validar en backend cada cambio de contexto. Accesos de `platform_superadmin` a datos de clientes deben registrar actor, contexto, motivo y tiempo; no implementar suplantación silenciosa.

## Firebase

Solo **FCM + Hosting**. Un proyecto Firebase por ahora (pre-prod). Sin Firestore/Auth.

## Releases móviles

Keystore / certificados en GitHub Secrets. Promoción a producción en tiendas = **manual**.
