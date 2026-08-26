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

- Done: migrations + RLS 001/002, **access model 003** + grants 004, **pgTAP RLS tests** (workflow `rls.yml`), Flutter UI (splash/login/home/add-news), GHA web workflows, remote GitHub.
- Next: cutover legacy → org/property, `db push` + seed, Supabase Auth + go_router.

## Core constraints

- Do not commit secrets (`.env`, service role, keystores, `google-services.json`).
- Do not disable RLS. Always design with `tenant_id`.
- Do not hardcode Diaz PH branding; product brand ≠ tenant brand.
- Target domain is organization → property → unit. Migration **003** adds the access model; SQL names `tenant`/`building` remain until cutover — do not mix models partially. See `docs/database/access-model.md`. Hotels are future extensibility, not MVP scope.
- Resolve branding as property → organization → Comunexa. MVP defaults to `co_branded`; removing Comunexa (`white_label`) is enterprise-only. Keep typography, components, layout, and accessibility product-controlled.
- **Assets:** always reuse `BrandAssets` / `assets/branding/` (logos, symbol, icons) before exporting from Figma; do not duplicate the same mark.
- B2B subscription may be paid by an organization or property and cover one or many properties; end users never pay for access. It is manually activated during the pilot and separate from paused resident payments. Onboarding uses private invitations or approval-required requests. Multi-role users select a context only when several exist; platform support context is separate and audited. See `docs/subscriptions-and-onboarding.md`.
- Security guards are a least-privilege `property_staff` preset, not a global role; access events are append-only. User media MVP accepts server-validated/re-encoded PNG/JPEG/WebP, not SVG. Native client name/icon require an enterprise white-label build; the shared app remains Comunexa. See `docs/access-control-and-media.md`.
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
