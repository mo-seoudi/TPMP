# Users & Security — Module Contract (Architecture Baseline)
**Status:** Architecture approved; detailed functional/UI/API specification not yet approved. **Decision references:** 01,14,15,16,20.

> **Amendments (2026-10-23):** D-22, D-23 in `../16_DECISION_AMENDMENTS.md` change phasing for this module; wording pending owner review.

## Required capabilities and invariants
Supabase Auth, multi-organization membership, hybrid RBAC, explicit typed scopes, policy-authorized hierarchy expansion, versioned grants, RLS and server authorization; supplier roles plus relationship grants; no blanket platform-admin client access; invitation and revocation history.

## Cross-module integration
Use documented typed interfaces and references; enforce tenant/resource authorization; preserve immutable history and audit; use the transactional outbox for asynchronous effects. No direct rewrite of another module's authoritative state.

## Component-by-component implementation rules
Define page composition, reusable components, inputs, validation, states, actions, role matrix, API contract, data persistence, audit and negative security tests before coding. Changing one component must not silently alter sibling components or the containing page.

## Explicitly unresolved
Complete permission-resource matrix, MFA policy, SSO provider, admin break-glass and invitation UX.

## Acceptance criteria framework
1. Correct authorized behavior and negative unauthorized/tenant-isolation tests.
2. Version history and proposed-versus-approved state preserved where relevant.
3. Module contract respected; no unrelated file/component modifications.
4. Database/API tests, UI interaction tests and regression tests pass.
5. Scope, test results, limitations and release state documented.
