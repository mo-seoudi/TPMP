# Personnel Management — Module Contract (Architecture Baseline)
**Status:** Architecture approved; detailed functional/UI/API specification not yet approved. **Decision references:** 05,09,10,15,16.

> **Amendments (2026-10-23):** A-02, A-05 in `../16_DECISION_AMENDMENTS.md` change phasing for this module; wording pending owner review.

## Required capabilities and invariants
Supplier-owned personnel profiles and immutable versions; client-specific assignments to engagements and locations; role/category-driven requirements; proposal, review, impact, compliance gate, activation, history; optional controlled identity link across suppliers.

## Cross-module integration
Use documented typed interfaces and references; enforce tenant/resource authorization; preserve immutable history and audit; use the transactional outbox for asynchronous effects. No direct rewrite of another module's authoritative state.

## Component-by-component implementation rules
Define page composition, reusable components, inputs, validation, states, actions, role matrix, API contract, data persistence, audit and negative security tests before coding. Changing one component must not silently alter sibling components or the containing page.

## Explicitly unresolved
Exact role catalog, assignment form, consent/verification procedure, operational activation policies.

## Acceptance criteria framework
1. Correct authorized behavior and negative unauthorized/tenant-isolation tests.
2. Version history and proposed-versus-approved state preserved where relevant.
3. Module contract respected; no unrelated file/component modifications.
4. Database/API tests, UI interaction tests and regression tests pass.
5. Scope, test results, limitations and release state documented.
