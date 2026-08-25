# Control de acceso y carga de imágenes — Comunexa

Decisión de arquitectura objetivo. No está implementada en las migraciones actuales.

## 1. Vigilancia como perfil de permisos

Vigilancia no se modela como otro rol global. Es un preset de permisos dentro de `property_staff`:

```text
role: property_staff
permission_preset: security_guard
```

Permisos iniciales:

- `view_expected_visits`
- `register_visit_entry`
- `register_visit_exit`
- `register_vehicle_entry`
- `register_vehicle_exit`
- `verify_resident_authorization`
- `view_access_history_limited`

No incluye facturación, PQR privadas, administración de miembros, publicaciones, configuración de propiedad ni acceso a otras propiedades. Los presets simplifican la asignación; RLS y backend validan permisos individuales. Otros presets futuros pueden ser `reception`, `maintenance` o `resident_support`.

## 2. Dominio de control de acceso

El modelo objetivo generaliza el registro actual de `visits`:

```text
visitors
- property_id
- name
- document_type, document_number

vehicles
- property_id
- plate, vehicle_type, color
- owner_profile_id opcional

visit_authorizations
- property_id, unit_id
- visitor_id, vehicle_id opcionales
- valid_from, valid_until
- authorized_by, status

access_events
- property_id, unit_id opcional
- visitor_id, vehicle_id opcionales
- event_type: entry | exit | denied | correction
- access_type: visitor | resident | contractor | delivery
- occurred_at, gate_or_location
- authorization_id opcional
- registered_by, notes
```

Casos cubiertos: visitantes esperados o espontáneos, vehículos, domicilios, proveedores, contratistas, autorizaciones temporales/recurrentes, accesos denegados y múltiples porterías.

Los eventos son append-only para operación normal. Una corrección referencia el evento previo, conserva actor, motivo y timestamp; vigilancia no borra historial.

## 3. Privacidad y retención

Documentos, placas, fotografías y horarios son datos personales/operativos. Antes del piloto real se debe definir aviso de privacidad, finalidad y plazo de retención aplicable.

- Acceso limitado a la propiedad y permiso concreto.
- Enmascarar documentos cuando el valor completo no sea necesario.
- Auditar consultas sensibles, exportaciones y correcciones.
- Sin exportación masiva para el preset `security_guard`.
- Retención y eliminación mediante proceso controlado, no indefinida.
- Reconocimiento facial fuera del MVP.

## 4. Pipeline seguro de imágenes

Toda imagen configurable —logo, portada, avatar u otra— se valida en dos niveles. Flutter hace validación temprana para UX; backend/Storage es la autoridad.

```text
selección
→ validación local y preview
→ carga temporal/autorizada
→ validación real en backend
→ decodificación y normalización
→ variantes optimizadas
→ publicación/versionado
```

Controles mínimos:

- verificar membresía y permiso de escritura;
- validar organización/propiedad de la ruta;
- allowlist MVP: PNG, JPEG y WebP;
- comprobar magic bytes y decodificar; no confiar en extensión o `Content-Type`;
- límites configurables de bytes, dimensiones y megapíxeles;
- rechazar archivos corruptos, bombas de descompresión y proporciones no admitidas;
- re-encodear a formatos seguros y eliminar EXIF/ubicación/metadatos;
- generar logo, miniatura y portada según uso;
- nombres opacos, rutas generadas por servidor, versión/cache busting y rate limiting;
- conservar el original solo si existe una necesidad definida y en ubicación privada.

**SVG subido por usuarios no se admite en el MVP.** Los SVG incluidos y revisados dentro del repositorio siguen permitidos. Una habilitación futura exige sanitización estricta y eliminación de scripts, eventos, referencias externas y contenido activo.

## 5. Calidad visual

- Vista previa light/dark antes de publicar.
- Contraste WCAG para colores configurables.
- Dimensiones y relación de aspecto por tipo de asset.
- Comportamiento definido para transparencia.
- Fallback propiedad → organización → Comunexa si un asset no existe o falla.
- La app consume variantes procesadas, nunca una carga sin validar.

## 6. Quality gate futuro

La implementación debe incluir tests RLS cross-property, permisos positivos/negativos de `security_guard`, inmutabilidad/corrección de eventos y archivos válidos, falsificados, sobredimensionados, corruptos y con metadatos.
