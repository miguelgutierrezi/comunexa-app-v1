/**
 * payment-webhook — STUB (pagos pausados en v1)
 *
 * Futuro: POST desde Wompi/PayU → validar firma → actualizar payments/invoices.
 * Esquema ya preparado (tablas invoices, payments). No implementar cobro hasta
 * que el producto lo requiera. Ver docs/technical-brief.md §6.
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve((_req) => {
  return new Response(
    JSON.stringify({
      ok: false,
      code: "PAYMENTS_PAUSED",
      message:
        "Integración de pasarela pausada en v1. Webhook no procesa cobros todavía.",
    }),
    {
      status: 501,
      headers: { "Content-Type": "application/json" },
    },
  );
});
