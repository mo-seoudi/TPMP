# TPMP — Complete AI Development Handover v2.0
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
