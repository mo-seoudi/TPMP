# Build Roadmap and Acceptance Criteria

## Phase 0 — Foundation (F0)
Review, correct and test schemas, privilege boundary, audit/outbox primitives and security harness. External checkpoint custody and trusted actor/worker paths are release blockers.

## Phase 1 — Organization and security base
Create legal entities, hierarchy, units, locations, user profiles, memberships, explicit access scopes and authorization tests. Validate no implicit descendant access. Establish scoped supplier user identities.

## Phase 2 — Shared suppliers and relationships
Supplier identity, identifiers, candidate review/merge, client–supplier relationships, engagements, service categories and locations. Verify no cross-client information leakage.

## Phase 3 — Supplier profiles, forms and documents
Versioned shared profile and independent client adoption, configurable fields, immutable document storage/metadata and consent-based sharing. Tests for pending versus approved state and revocation.

## Phase 4 — Compliance and approvals
Template assignment, requirement exceptions, evidence assessments, validity, workflow definitions/bindings, reviewer eligibility, delegation/escalation, audit. Test client-specific approvals and expiry.

## Phase 5 — Personnel and contracts
Supplier personnel and assignment activation gates; contracts, parties, amendments, effective terms, obligations and compliance links. Test source provenance and independent decisions.

## Phase 6 — Reporting, administration and integrations
Metrics/projections/reconciliation, client configuration, notifications, scheduled jobs, export controls and operational dashboards.

## Delivery method for every module
1. Scope and user stories.
2. Data contract and security matrix.
3. Reusable component inventory and UI contract.
4. API/event contract and acceptance tests.
5. Migrations and tests on disposable database.
6. Component-level implementation with no unrelated changes.
7. Integration and regression tests.
8. Staging review and explicit release approval.
9. Versioned change log and decision register update.

## Definition of done
Correct authorization and tenant isolation; lifecycle and audit completeness; concurrency/temporal correctness; accessibility/responsiveness; documented migrations; tests; no unrequested feature changes; approved deployment. A feature is not done merely because the UI works.

## Suggested first end-to-end vertical slice
Client admin creates organization scope -> supplier relationship -> supplier submits basic profile/doc -> client reviews version -> requirement status updates -> audit event and outbox -> authorized dashboard view. Keep scope narrow and demonstrate RLS and approval isolation before expanding modules.
