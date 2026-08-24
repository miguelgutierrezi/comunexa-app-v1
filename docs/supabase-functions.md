# Supabase Edge Functions — Comunexa

Lógica server-side en **Deno** bajo `supabase/functions/`.

## Estructura

```
supabase/
├── migrations/
├── functions/
│   ├── _shared/
│   │   ├── supabase-admin.ts
│   │   ├── fcm.ts
│   │   └── cors.ts
│   ├── send-push/
│   ├── generate-visit-pdf/
│   ├── generate-monthly-invoices/
│   ├── on-news-published/
│   └── payment-webhook/          # STUB — pagos pausados en v1
└── config.toml
```

## Funciones

| Función | Estado v1 | Disparador | Responsabilidad |
|---|---|---|---|
| `send-push` | Implementar | HTTP autenticado | FCM + `notifications_log` |
| `on-news-published` | Implementar | Webhook `news` INSERT | Push por `building_id` |
| `generate-visit-pdf` | Implementar | App tras visita | PDF + Storage + URL |
| `generate-monthly-invoices` | Implementar | `pg_cron` | Crear filas `invoices` (sin cobro) |
| `payment-webhook` | **Stub** | POST Wompi/PayU | Pausado: responde 501; diseño futuro sin cambiar tablas |

## Pagos (pausado)

La v1 **no** integra pasarela. Las tablas `invoices` y `payments` existen; el módulo de facturación muestra estado de cuotas **sin** checkout.

Cuando se reactive:

1. Checkout en app → Wompi/PayU  
2. Webhook → `payment-webhook` (validar firma HMAC)  
3. Actualizar `payments` + `invoices`  
4. Comprobante en Storage  

Ver stub: [`../supabase/functions/payment-webhook/index.ts`](../supabase/functions/payment-webhook/index.ts)

## Secrets

| Secret | Uso | ¿v1? |
|---|---|---|
| `FCM_SERVER_KEY` / service account | Push | Sí |
| `SUPABASE_SERVICE_ROLE_KEY` | Functions | Sí |
| `WOMPI_EVENTS_SECRET` / `PAYU_*` | Webhooks pago | No (hasta reactivar) |

```bash
supabase secrets set FCM_SERVER_KEY=...
```

## Seguridad

- Service role solo en functions, con validación JWT / firma webhook / secret.
- PDF: branding del tenant; no filtrar PII entre tenants.

## Local / deploy

```bash
supabase functions serve send-push --env-file supabase/.env.local
supabase functions deploy send-push --project-ref <ref>
```
