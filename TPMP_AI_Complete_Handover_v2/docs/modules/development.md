# Development & Deployment — Module Contract (Architecture Baseline)
**Status:** Architecture approved; detailed functional/UI/API specification not yet approved. **Decision references:** 18,19,20,21.

> **Amendments (2026-10-23):** A-01, D-22, D-24 in `../16_DECISION_AMENDMENTS.md` change phasing for this module; wording pending owner review.

## Required capabilities and invariants
React + TypeScript modular monolith; Supabase PostgreSQL/Auth/Storage; Vercel; GitHub; typed interfaces; F0 foundation first; one migration history; isolated environments; tests, previews, staged release approvals; no production deployment without authorization.

## Cross-module integration
Use documented typed interfaces and references; enforce tenant/resource authorization; preserve immutable history and audit; use the transactional outbox for asynchronous effects. No direct rewrite of another module's authoritative state.

## Component-by-component implementation rules
Define page composition, reusable components, inputs, validation, states, actions, role matrix, API contract, data persistence, audit and negative security tests before coding. Changing one component must not silently alter sibling components or the containing page.

## Explicitly unresolved
Final framework choice beyond React/TS, API runtime for non-database concerns (uploads, email, workers; user commands follow D-22), CI provider, exact environments, disaster recovery targets.

## Acceptance criteria framework
1. Correct authorized behavior and negative unauthorized/tenant-isolation tests.
2. Version history and proposed-versus-approved state preserved where relevant.
3. Module contract respected; no unrelated file/component modifications.
4. Database/API tests, UI interaction tests and regression tests pass.
5. Scope, test results, limitations and release state documented.
