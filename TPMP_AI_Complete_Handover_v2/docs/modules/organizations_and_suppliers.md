# Organizations & Suppliers — Module Contract (Architecture Baseline)
**Status:** Architecture approved; detailed functional/UI/API specification not yet approved. **Decision references:** 01,02,03,04,15,16.

> **Amendments (2026-10-23):** A-05, D-23 in `../16_DECISION_AMENDMENTS.md` change phasing for this module; wording pending owner review.

## Required capabilities and invariants
Stable legal entities, hierarchy, operating units, locations, explicit membership scopes; global supplier matching with reviewed merges; independent client relationship/engagement; shared supplier-maintained profile and client adoption/field decisions.

## Cross-module integration
Use documented typed interfaces and references; enforce tenant/resource authorization; preserve immutable history and audit; use the transactional outbox for asynchronous effects. No direct rewrite of another module's authoritative state.

## Component-by-component implementation rules
Define page composition, reusable components, inputs, validation, states, actions, role matrix, API contract, data persistence, audit and negative security tests before coding. Changing one component must not silently alter sibling components or the containing page.

## Explicitly unresolved
Exact UI fields, required legal identifiers per jurisdiction, status labels, final hierarchy screen.

## Acceptance criteria framework
1. Correct authorized behavior and negative unauthorized/tenant-isolation tests.
2. Version history and proposed-versus-approved state preserved where relevant.
3. Module contract respected; no unrelated file/component modifications.
4. Database/API tests, UI interaction tests and regression tests pass.
5. Scope, test results, limitations and release state documented.
