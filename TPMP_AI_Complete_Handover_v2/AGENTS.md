# TPMP Agent Instructions — Binding Working Protocol

## Before each task
Read `README.md`, `docs/02_DECISION_REGISTER.md`, `docs/11_DETAILED_APPROVED_DECISIONS.md`, `docs/05_SECURITY_PRIVACY_AND_GOVERNANCE.md`, `docs/07_DATABASE_AND_DEPLOYMENT_STRATEGY.md`, `docs/14_IMPLEMENTATION_STATE.md`, and the relevant module brief. Do not infer that a design is implemented.

## Rules
1. Preserve approved decisions 01–21 and foundational architecture principles 01–16 unless user explicitly authorizes a numbered change.
2. Treat the platform as an independent, industry-neutral, multi-tenant SaaS; do not couple it to a specific employer, school or supplier.
3. Propose a plan listing affected files, tables, endpoints, components, permission changes, migrations and tests **before editing**; await explicit approval for implementation.
4. Work on the requested module/component only. No opportunistic refactoring, visual redesign, dependency upgrades, scope expansion or silent behavior changes.
5. Use module-owned typed tables, explicit tenant integrity, RLS, immutable approved versions, trusted server-side authorization and a transactional outbox.
6. A supplier's shared identity is not a shared client approval. Never leak one client's records, reviews, pricing, contracts or personnel data to another.
7. Supplier edits requiring review must create a proposed version; approved valid version remains effective until replacement activation. Pending replacement does not extend expiry.
8. Preserve separate review, validity, change and operational authorization statuses.
9. Document any unknown detail as OPEN, not APPROVED. Never invent precise UI fields, status enumerations, APIs or policy durations.
10. Use independent branch and reviewable commits; test security boundaries, concurrency, history, and regression. Never deploy without explicit authorization.
11. Never place secrets or privileged Supabase keys in browser code or committed files. Do not grant general `service_role` execution as a shortcut.
12. Update decision log, module spec, task state and changelog only for approved changes; report tests honestly.

## Response contract for coding tasks
Return: (a) scope understanding, (b) approved requirements, (c) open questions, (d) files and cross-module dependencies, (e) implementation plan, (f) test plan, (g) risks. Stop for approval before editing. After approved work: summarize actual diffs, tests run/failures, and deployment status.
