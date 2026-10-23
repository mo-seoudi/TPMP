# Build Roadmap and Acceptance Criteria

> **Revised 2026-10-23** per A-01…A-05 and D-22…D-24 (`16_DECISION_AMENDMENTS.md`); wording pending owner review. Replaces the earlier six-phase sequence, which placed approvals (Phase 4) after documents and profiles (Phase 3) that need them.

## MVP definition (approved in principle)
A client organization can onboard a supplier, assign requirements from templates, receive evidence, review it through a one- or two-stage approval, and see expiry status. In scope: organizations with explicit memberships and a flat or shallow hierarchy; supplier registry with manual reviewed matching; relationships and engagements; requirement templates; immutable document versions; the minimal approval primitive (A-03); expiry tracking with outbox-driven email reminders; append-only audit (A-01); live-query dashboard (A-04). Deferred: contracts, cross-supplier personnel linking, evidence reuse, projections, delegation and escalation, configuration governance, hash chaining. Items marked OPEN in `10` remain blockers where noted.

## Phase 0 — Specification closure and F0 hardening
Close the OPEN items that block F1: tenancy and ownership (`17`, D-23), data residency and legal basis (no real personal data before decided), status vocabularies and permission matrix for F1 tables, API runtime, CI provider. Revise F0 per A-01 and D-22, then run F0 on a disposable database with role-based, concurrency and rollback tests. Release blockers: trusted worker path, immutability triggers, segment/outbox findings in `14`.

## Phase 1 — Organization and security base
Legal entities, hierarchy (flat or shallow first), memberships, explicit scopes, supplier-user identities, D-22 command pattern, RLS tests. Validate no implicit descendant access.

## Phase 2 — Suppliers and relationships
Registry with stub and claim flow, manual matching, client–supplier relationships, engagements, service categories, locations. Verify no cross-client leakage.

## Phase 3 — Documents, evidence and minimal approval
Immutable document versions and private storage (with upload security controls), requirement templates and assignments, evidence assessment, validity and expiry, the minimal approval primitive, consent-based sharing, reminders via outbox, the first end-to-end slice. Tests for pending versus approved state, expiry not extended by pending replacement, revocation.

## Phase 4 — Supplier profiles and personnel
Versioned shared profile with independent client adoption, configurable fields, supplier-scoped personnel and assignment activation gates.

## Phase 5 — Full workflow, contracts and reporting
Delegation, reassignment, escalation, parallel stages, workflow designer; contracts with manual effective terms and obligation tracking; projections, reconciliation, configuration governance; hash-chained audit and external anchoring when its trigger condition (A-01) is met; notifications and administration.

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

## Suggested first end-to-end vertical slice (delivered in Phase 3)
Client admin creates organization scope -> supplier relationship -> supplier submits a document -> client reviews version through the minimal approval -> requirement status updates -> audit event and outbox -> authorized dashboard view. Keep scope narrow and demonstrate RLS and approval isolation before expanding modules.
