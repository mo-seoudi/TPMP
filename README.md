# TPMP — Complete AI Development Handover v2.0

> **Path note (2026-10-23):** `README.md`, `AGENTS.md` and `CLAUDE.md` sit at the repository root, but the `docs/`, `tasks/`, `sources/` and `implementation/` folders they reference live under `TPMP_AI_Complete_Handover_v2/`. Read `docs/...` as `TPMP_AI_Complete_Handover_v2/docs/...`. Amendments from the architecture review are in `TPMP_AI_Complete_Handover_v2/docs/16_DECISION_AMENDMENTS.md` (branch `claude-v1.0`, wording pending owner review).

**Status: reference baseline, 23 October 2026. No deployment.**

## How to use this package
1. Read `AGENTS.md` (or `CLAUDE.md`), then `docs/00_START_HERE.md`, `docs/01_PRODUCT_CHARTER_AND_SCOPE.md`, `docs/02_DECISION_REGISTER.md` and `docs/11_DETAILED_APPROVED_DECISIONS.md`.
2. Read the relevant module specifications under `docs/modules/` and the security, data and development guidelines.
3. Consult `docs/15_SOURCE_COVERAGE_AND_UNCERTAINTY.md` before claiming any detail is agreed. Original source PDF and the prior reference library are in `sources/`.
4. Check `docs/14_IMPLEMENTATION_STATE.md` to distinguish specification from implemented and tested functionality.
5. Work from an approved task in `tasks/approved/`, using `tasks/templates/FEATURE_TASK.md`.
6. Present a change plan and affected files before code changes. No deployment without authorization.

## Authority order
Explicit latest user approval > numbered approved decisions > module-specific approved specification > product architecture guidelines > examples and proposals. A new assistant suggestion is not approval. If sources conflict, flag the conflict and seek a decision; do not silently resolve it.

## Contents
- `docs/00`–`10`: original baseline product, decision, domain, workflow, security, UI, database, F0, roadmap and open questions documents.
- `docs/11`–`15`: expanded decisions, module contracts, AI working protocol, implementation state, source coverage.
- `docs/modules/`: individual module implementation briefs with approved invariants and unresolved details.
- `AGENTS.md`, `CLAUDE.md`: persistent AI agent instructions.
- `tasks/templates/FEATURE_TASK.md`: scoped work order template.
- `sources/`: supporting source and prior Word reference.
- `implementation/`: F0 review-only SQL ZIP; not validated or deployed.
- `TPMP_Master_AI_Reference_v2.0.docx`: editable consolidated reference for reading.

**Completeness note:** This package consolidates all substantive approved details available in the current project context and attached source material. It is not a verbatim archive of every project conversation. Where original chats are not available, claims of literal exhaustive coverage would be misleading. See `docs/15_SOURCE_COVERAGE_AND_UNCERTAINTY.md`.

## Application and database (branch `claude-v1.0`)
- `src/` — React + TypeScript (Vite) application shell. No business modules are built; see `src/modules/registry.ts`.
- `supabase/migrations/` — F0 foundation (audit ledger, outbox), revised per amendments A-01 and D-22.
- `supabase/tests/` and `scripts/db-test.sh` — SQL tests on a disposable PostgreSQL (`npm run test:db`; needs `psql` and a superuser connection).
- `npm install && npm run dev` to run the app; copy `.env.example` to `.env.local` first. Only the public anon key is ever used in browser code.
- `.github/workflows/ci.yml` runs lint, typecheck, unit tests, build and the database suite. `vercel.json` configures a Vite SPA deployment.
- Status and limits: `TPMP_AI_Complete_Handover_v2/docs/14_IMPLEMENTATION_STATE.md`.
