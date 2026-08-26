# Suscripciones y onboarding — Comunexa

Decisión de producto objetivo. No está implementada en las migraciones actuales.

## 1. Principio comercial

Comunexa es un SaaS **B2B por suscripción**. La entidad pagadora puede ser la organización administradora o la propiedad/conjunto que recibe el servicio. Residentes, propietarios y demás usuarios finales no pagan por registrarse ni acceder.

La suscripción de la organización es independiente de los pagos operativos de residentes:

| Flujo | Quién paga | Estado |
|---|---|---|
| Suscripción Comunexa | Organización o propiedad → Comunexa | Piloto: factura y activación manual |
| Cuotas, reservas u otros cobros | Miembro → organización/propiedad | Pausado; sin checkout en v1 |

Documentar la suscripción no reactiva Wompi/PayU ni autoriza completar `payment-webhook`.

## 2. Unidad de cobro

Modelo recomendado:

```text
cargo base por organización
+ unidades activas administradas
+ complementos opcionales
```

Se cobra por **unidades activas**, no por usuarios, porque una unidad puede vincular propietario, arrendatario, familiares u otros autorizados. Esto evita penalizar la adopción.

La facturación se desacopla de la operación: una administradora puede pagar una factura consolidada que cubre varias propiedades; un conjunto puede pagar directamente aunque una administradora lo opere; y una suscripción puede cubrir una o varias propiedades.

Entidades objetivo:

```text
billing_accounts
- payer_type: organization | property
- organization_id
- property_id opcional
- legal_name, tax_id, billing_email

subscriptions
- billing_account_id
- plan_id, status
- starts_at, trial_ends_at, grace_ends_at

subscription_properties
- subscription_id
- property_id
```

No se fijan precios todavía: deben validarse durante el piloto con Diaz PH. El superadministrador de plataforma registra inicialmente plan, vigencia y estado de forma manual.

## 3. Niveles de suscripción

| Plan conceptual | Segmento | Capacidades orientativas |
|---|---|---|
| `essential` | Propiedad u organización pequeña | Noticias, miembros, visitas, PQR y soporte estándar |
| `management` | Administradoras con varias propiedades | Reservas, facturación informativa, votaciones, reportes y branding por propiedad |
| `enterprise` | Operaciones grandes o integradas | Límites ampliados, auditoría, integraciones, soporte prioritario y opción `white_label` |

Complementos posibles: almacenamiento, reportes avanzados, integraciones, soporte premium y white label. Las invitaciones y solicitudes de ingreso forman parte del acceso básico y no deben ser un add-on.

Las capacidades finales se controlarán mediante entitlements del plan; no mediante condicionales dispersos en Flutter.

## 4. Ciclo de vida

Estados objetivo:

```text
trialing → active → past_due → suspended → cancelled
```

- `trialing`: prueba limitada por fecha, unidades o propiedades.
- `active`: acceso normal según plan.
- `past_due`: avisos y periodo de gracia.
- `suspended`: operación restringida, preferiblemente solo lectura y exportación.
- `cancelled`: suscripción terminada; retención y eliminación según política contractual.

No se eliminan datos inmediatamente por mora. La autorización se aplica en backend/RLS o servicios confiables; ocultar pantallas en Flutter no es control suficiente.

## 5. Alta de miembros

El MVP usa dos flujos complementarios.

### Invitación privada

```text
Administrador selecciona propiedad/unidad
→ genera invitación para correo o teléfono
→ usuario abre enlace o ingresa token
→ crea/inicia sesión
→ acepta vínculo
```

Una invitación privada puede aprobar automáticamente el vínculo si fue emitida para una persona y unidad concretas. El token debe ser aleatorio, de un solo uso o uso limitado, expirable, revocable y almacenado como hash. No debe contener PII ni IDs confiables en texto legible.

### Solicitud para unirse

```text
Usuario ingresa código público de propiedad
→ identifica su unidad y relación
→ envía solicitud
→ responsable revisa
→ aprueba o rechaza
```

El código público solo descubre la propiedad y abre una solicitud: **nunca concede acceso**. Conocer el código, dirección o nombre de una propiedad no permite leer datos privados.

## 6. Invitaciones, solicitudes y ocupaciones

Entidades objetivo, a concretar en migraciones nuevas (occupancies ya en **003**):

- `property_join_codes`: código público rotatable para iniciar solicitudes.
- `property_invitations`: token privado, destinatario opcional, propiedad/unidad, expiración, usos y estado.
- `membership_requests`: solicitante, propiedad, unidad declarada, relación, evidencia opcional, estado y auditoría de revisión.
- `occupancies` (**003**): vínculo aprobado entre perfil y unidad, tipo, vigencia y estado.

Estados de solicitud:

```text
pending → approved
        → rejected
        → cancelled
        → expired
```

Relaciones PH iniciales: `owner`, `tenant`, `authorized_resident`, `representative`. `guest` queda reservado para una extensión hotelera futura.

Una identidad puede mantener múltiples ocupaciones y membresías; cerrar una ocupación no elimina su historial.

## 7. Permisos y auditoría

- `organization_admin`: invita, aprueba y administra miembros en todas sus propiedades.
- `property_manager`: invita y aprueba en propiedades asignadas.
- `property_staff`: solo si recibe el permiso explícito `manage_members`.
- `member`: acepta invitaciones propias, solicita acceso y cancela solicitudes propias.

Registrar `created_by`, `reviewed_by`, timestamps, estado y motivo de rechazo. Limitar intentos, rotar códigos públicos ante abuso y notificar al usuario de cada decisión.

## 8. Flujo recomendado para el piloto

1. El superadministrador de Comunexa crea la organización, define si paga la administradora o el conjunto y registra manualmente la suscripción.
2. El administrador de organización configura propiedades y unidades.
3. Invita miembros mediante enlace, token o QR privado.
4. Quien no tenga invitación usa el código público y solicita ingreso.
5. Un responsable autorizado verifica propiedad, unidad y relación.
6. Al aprobar, se crean membresía y ocupación con acceso RLS contextual.
7. Al mudarse o terminar una relación, se cierra la ocupación sin borrar el historial.

La automatización de cobro de la suscripción se decide después de validar planes, métricas y precio con el piloto.

## 9. Selección de contexto multirrol

El login autentica una identidad; no fija un rol global. Después se resuelven sus membresías y contextos disponibles:

```text
perfil
├── consola Comunexa — platform_superadmin
├── Propiedad A — property_manager
├── Propiedad B — property_staff
└── Propiedad C — member
```

- Un solo contexto disponible: entrada directa.
- Varios contextos: pantalla **“¿A dónde quieres entrar?”**.
- Recordar el último contexto válido y permitir cambiarlo desde el menú sin cerrar sesión.
- Una invitación o deep link puede proponer un contexto, pero siempre se valida la membresía.
- La tarjeta muestra propiedad, organización y función; se selecciona el contexto, no un rol aislado.

Si una identidad acumula varios permisos en una misma propiedad, el backend calcula permisos efectivos. Cuando sea necesario separar experiencias sensibles —por ejemplo, administrador y miembro— se ofrecen entradas contextuales distintas.

La consola `platform_superadmin` es un contexto separado. Entrar a una organización o propiedad para soporte no equivale a suplantar silenciosamente a un usuario: requiere autorización explícita y auditoría de actor, contexto, motivo y tiempo.
