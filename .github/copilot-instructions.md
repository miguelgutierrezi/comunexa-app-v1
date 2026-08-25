# Copilot instructions for Comunexa (`comunexa-app-v1`)

Use these notes as the default context for this repository.

## Project context

- Flutter SaaS **white-label multi-tenant** for property-management companies (PH), Colombia first. Pilot: Administradores Diaz PH SAS.
- Backend: **Supabase** (Postgres + Auth + Storage + RLS + Edge Functions). Push: **FCM**. Web hosting: **Firebase Hosting**. CI: **GitHub Actions**.
- **Not** Firestore / Firebase Auth. Do not copy code from `administradores-diaz-ph-v2`.
- In-app payments are **paused** (`payment-webhook` is a stub). Schema for `invoices`/`payments` exists.

## Read first

1. `AGENTS.md`
2. `docs/technical-brief.md`
3. `docs/roadmap.md` (current phase status)
4. Task-specific: `docs/architecture.md`, `docs/flutter-structure.md`, `docs/database/`, `docs/security.md`, `docs/ci-cd.md`

## Current code status (2026-08-25)

- Done: migrations + RLS, Flutter bootstrap, theme/branding, splash, **responsive login UI** (auth still stub; **Apple button only on iOS/macOS**; bypass → home; demo alert emails), **home shell mock** (mobile + tablet portrait/landscape + desktop, light/dark), GHA workflows, remote GitHub.
- Next: Supabase project + `supabase_flutter` + go_router + real Auth + SessionProvider.

## Core constraints

- Do not commit secrets (`.env`, service role, keystores, `google-services.json`).
- Do not disable RLS. Always design with `tenant_id`.
- Do not hardcode Diaz PH branding; product brand ≠ tenant brand.
- Do not implement Wompi/PayU or complete `payment-webhook` unless explicitly asked.
- Keep changes minimal. Treat login bypass / mock home as **UI only**, not real session.
- Reply to the user in **Spanish**. UI strings in Spanish; code identifiers in English.

## Quality gate (mandatory before finishing a code change)

```bash
flutter analyze
flutter test
flutter build web --release
```

All three must pass (same as `web.yml`). Docs-only changes skip the build.

### Tests

- New behavior/screens → add unit/widget tests **in the same change** (prefer `test/features/<feature>/`).
- Bug fixes → add a regression test when reasonable.

### Documentation + all 3 agent surfaces

If the change affects behavior, schema, phases, `lib/` layout, or conventions, update **in the same change**:

1. Relevant files under `docs/`
2. `AGENTS.md` and `CLAUDE.md`
3. `.cursor/rules/` (at least keep `project-core.mdc` / `quality-gate.mdc` coherent)
4. This file: `.github/copilot-instructions.md`

The three agent surfaces must stay aligned. See `.cursor/rules/quality-gate.mdc` and `AGENTS.md`.

## Codebase conventions

- Package imports: `package:comunexa/...`.
- Target layout: `lib/features/<name>/{data,domain,presentation}/`.
- Riverpod for state; go_router planned (not wired yet — do not invent a second navigation system without aligning `app.dart`).
- `presentation` must not call Supabase directly; use repositories in `data/`.
- Conventional Commits.
