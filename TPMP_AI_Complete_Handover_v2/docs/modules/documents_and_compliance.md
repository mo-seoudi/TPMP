# Documents & Compliance — Module Contract (Architecture Baseline)
**Status:** Architecture approved; detailed functional/UI/API specification not yet approved. **Decision references:** 04,05,06,07,08,18.

> **Amendments (2026-10-23):** A-02, A-05 in `../16_DECISION_AMENDMENTS.md` change phasing for this module; wording pending owner review.

## Required capabilities and invariants
Private storage and immutable document versions, metadata/virtual folders, document- and version-specific shares; requirements from versioned templates with exceptions; validity distinct from review; evidence assessments and controlled within-client reuse; expiry/renewal; approved version remains until replaced only while valid.

## Cross-module integration
Use documented typed interfaces and references; enforce tenant/resource authorization; preserve immutable history and audit; use the transactional outbox for asynchronous effects. No direct rewrite of another module's authoritative state.

## Component-by-component implementation rules
Define page composition, reusable components, inputs, validation, states, actions, role matrix, API contract, data persistence, audit and negative security tests before coding. Changing one component must not silently alter sibling components or the containing page.

## Explicitly unresolved
Requirement catalogs, specific evidence types, grace periods, expiry reminders, default approval sensitivity.

## Acceptance criteria framework
1. Correct authorized behavior and negative unauthorized/tenant-isolation tests.
2. Version history and proposed-versus-approved state preserved where relevant.
3. Module contract respected; no unrelated file/component modifications.
4. Database/API tests, UI interaction tests and regression tests pass.
5. Scope, test results, limitations and release state documented.
