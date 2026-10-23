# Approved Decision Register
**Interpretation:** Options below record approved *outcomes*, not verbatim meeting transcripts. All Core Data Model decisions 01–21 are approved as of 23 October 2026.

## Foundational architecture principles (approved before detailed data decisions)
1. Shared supplier identity; client-independent compliance and relationship decisions.
2. Supplier-maintained shared profile; client-specific approved adoption snapshots.
3. Supplier-scoped personnel; client-specific assignments and compliance.
4. Template-assigned requirements with authorized per-supplier overrides and impact review.
5. Configurable multi-stage and field-level approvals; immutable review history.
6. Scoped hybrid RBAC, Supabase Auth, RLS and server-side authorization.
7. Private Supabase Storage, immutable document versions and controlled sharing.
8. Configurable retention, archival, anonymization, deletion and legal holds.
9. Transactional events/outbox, notifications, scheduled checks, retries and idempotency.
10. Relationship-based contracts with parties, amendments, obligations and milestones.
11. Configurable versioned custom fields/forms and protected core fields.
12. Versioned organization configuration with preview, impact analysis and controlled activation.
13. Shared PostgreSQL with logical schemas and tenant isolation.
14. Modular monolith, typed interfaces, reusable components and regression tests.
15. Isolated dev/staging/prod, CI/CD, controlled migrations and release approval.
16. Specification-first, module-by-module implementation.

## Core Data Model Decisions
| No. | Approved option | Decision and non-negotiable implication |
|---|---|---|
| 01 | C | Legal entities, configurable hierarchy, operating units, locations and explicitly scoped memberships; no inherited blanket access. |
| 02 | C | Jurisdiction-aware supplier identity matching; reviewed candidate/merge workflow, never silent client-record merges. |
| 03 | C | Shared supplier profile versions and independent client adoption/field approvals; preserve approved snapshots. |
| 04 | C | Relational typed core plus validated, versioned JSONB for configurable fields and snapshots. |
| 05 | C | Compliance subjects/assignments at relationship, engagement, location and personnel-assignment levels; template versioning and exceptions. |
| 06 | C | Controlled evidence approval reuse only within a client under equivalence/coverage/validity policies; independent assignment decisions. |
| 07 | C | Immutable document versions and effective-evidence lifecycle; pending replacements never extend expired evidence. |
| 08 | C | Document-level and version-level sharing with controlled future-version consent, revocation and historical retention. |
| 09 | C | Supplier-scoped personnel with verified, controlled cross-supplier identity linking; no automatic data or approval sharing. |
| 10 | C | Versioned personnel assignment proposals, approval, impact checks, compliance gates and transactional activation. |
| 11 | C | Immutable agreements/amendments; versioned consolidated effective terms with provenance, obligations, milestones and financial terms. |
| 12 | C | Linked but independent contract obligations and compliance requirements; no silent outcome rewriting. |
| 13 | C | Shared versioned workflow engine with organization bindings, reviewer rules, append-only decisions and outbox events. |
| 14 | C | Time-limited reviewer delegation, authorized reassignment and escalation with separation of duties and audit. |
| 15 | C | Explicit access scopes, policy-authorized hierarchy expansion, versioned grants, impact review and immediate revocation. |
| 16 | C | Supplier-user identities and relationship-scoped access; supplier membership + supplier role + client grant + resource checks. |
| 17 | C | Hybrid live queries and controlled reporting projections, versioned metrics, snapshots, provenance and reconciliation. |
| 18 | C | Standard temporal conventions, module-owned typed version tables, recorded/effective time, immutable history, current pointers and optimistic concurrency. |
| 19 | C | Dependency-ordered modular migrations, one coordinated history, shared schema contracts, expand-and-contract, RLS tests and staged deployment. |
| 20 | C | Central append-only audit ledger plus module-specific immutable history, trusted writes, verification, retention and legal holds. |
| 21 | C | Segmented hash chains, independently protected checkpoints, controlled retention boundaries, legal holds and documented erasure/redaction. |

## Decision governance
A new feature proposal does not override these decisions. To change an approved decision: identify the number; describe the current rule, proposed replacement, migration and security impacts; seek explicit approval; update this register and impacted module documents. Never change approved behavior silently.
