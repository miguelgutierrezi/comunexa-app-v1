# Convenciones de código — Comunexa

Para mantener consistencia desarrollando en solitario o con agentes de IA.

## Idioma

- **UI y mensajes al usuario:** español.
- **Código** (clases, variables, commits técnicos): inglés.
- **Documentación:** español.

## Git y commits

Formato [Conventional Commits](https://www.conventionalcommits.org/):

```
tipo(alcance): descripción breve en imperativo

feat(auth): add Supabase login screen
fix(billing): correct invoice status filter
docs: update RLS policies for visits
chore(ci): add flutter analyze workflow
```

Tipos: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`.

Ramas:

- `main` — rama principal; deploy web a Hosting
- `feat/<nombre>` — features
- `fix/<nombre>` — correcciones

## Dart / Flutter

- `flutter analyze` sin issues antes de merge.
- Preferir `const` constructors donde aplique.
- Imports: `package:comunexa/...` (orden: dart → flutter → packages → relative).
- Archivos: `snake_case.dart`; clases: `PascalCase`.
- Widgets: sufijo `Screen` para pantallas, `Widget` para componentes reutilizables.

### Assets de marca e iconografía

- **Reutilizar siempre** antes de exportar de Figma: revisar `assets/branding/` y constantes en [`BrandAssets`](../lib/core/theme/brand_assets.dart).
- Logos / símbolo Comunexa: preferir `symbolGradientLight` / `symbolGradientDark`, `symbolLarge`, `markColor`, `logoHorizontal`, etc. No duplicar SVG del mismo mark.
- Iconos UI: usar las rutas ya listadas en `BrandAssets` (`icon-*`). Solo descargar de Figma si no existe equivalente.
- Nuevos assets → añadir constante en `BrandAssets` en el mismo cambio; no hardcodear paths sueltos en widgets.
- Branding de producto (`BrandAssets`) ≠ branding de tenant (futuro).

## Riverpod

- Providers en `*_provider.dart` junto a la feature.
- `@riverpod` o `Provider`/`Notifier` según complejidad; ser consistente dentro de una feature.
- No pasar `BuildContext` a repositorios.

## Supabase / SQL

- Migraciones numeradas: `001_`, `002_`, … — nunca editar migraciones ya aplicadas en prod; crear nueva migración.
- Nombres de tablas: `snake_case` plural (`buildings`, `resident_units`).
- PKs: `uuid` con `gen_random_uuid()`.
- Timestamps: `timestamptz`, columnas `created_at` / `updated_at`.
- Toda tabla de negocio: `tenant_id` indexado.

## Modelos

- Domain models con **freezed** + `json_serializable`.
- DTOs en `data/` si difieren del domain.
- Mapeo explícito en repositorio; no exponer `Map<String, dynamic>` a presentation.

## Seguridad

- No commitear `.env`, keys, `google-services.json`, service role.
- No usar service role en Flutter.
- Toda query asume RLS — no “confiar” en filtros solo en Dart.

## Tests

- Unit tests para repositorios y lógica domain.
- Widget smoke tests para pantallas críticas (login, home) en `test/features/<feature>/`.
- Tests de RLS en CI (script o Supabase local).
- **Mandatorio:** lo nuevo en una tarea lleva tests en el mismo cambio.

## Quality gate local (mandatorio)

Antes de dar por terminado un cambio de código (agentes o humano):

```bash
flutter analyze
flutter test
flutter build web --release
```

Alineado con [`.github/workflows/web.yml`](../.github/workflows/web.yml). Si falla alguno → no cerrar la tarea.

Solo documentación/reglas (sin Dart): no exige build.

## Documentación y agentes (mandatorio)

Impacto en comportamiento, schema, fases, estructura o convenciones → actualizar en el mismo cambio:

1. `docs/` pertinente  
2. Las **3** superficies de agentes, alineadas:
   - Cursor: `.cursor/rules/`
   - Claude / genérico: `AGENTS.md`, `CLAUDE.md`
   - GitHub Copilot: `.github/copilot-instructions.md`

Regla canónica para agentes: [`.cursor/rules/quality-gate.mdc`](../.cursor/rules/quality-gate.mdc) · [`AGENTS.md`](../AGENTS.md).

## CI / releases

- Web: merge a `main` → Hosting.
- Móvil: tag `vX.Y.Z` → TestFlight / Play internal; prod stores = manual.
- No añadir jobs iOS en cada PR (costo macOS).

## Pagos

No reactivar pasarela ni “completar” `payment-webhook` sin acuerdo explícito.

## PR / revisión (solo o con IA)

Checklist antes de cerrar tarea:

1. ¿RLS cubre la tabla tocada?
2. ¿`tenant_id` en datos nuevos?
3. ¿Sin secretos en diff?
4. ¿Tests nuevos/actualizados + `analyze` / `test` / `build web` en verde?
5. ¿Docs + reglas Cursor / Claude / Copilot actualizadas si hubo impacto?
