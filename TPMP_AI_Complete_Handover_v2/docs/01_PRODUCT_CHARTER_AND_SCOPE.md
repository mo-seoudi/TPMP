# Product Charter, Platform Guidelines and Scope

## Vision
Build an independent, configurable third-party and supplier management SaaS inspired by the functional breadth of Gatekeeper, without copying its interface or tying the product to one school group. The platform helps organizations onboard, govern, monitor and work with suppliers and their personnel, evidence, engagements and agreements.

## Core product principles
- **Independent multi-tenant SaaS:** multiple client organizations and multiple suppliers; each client's confidential relationship, requirements and decisions remain isolated.
- **Supplier reuse without client-data leakage:** a supplier can maintain a shared identity and profile; each client independently adopts, approves and evaluates it.
- **Compliance by policy:** templates assign requirements automatically based on categories, roles, engagement and location; authorized admins can tailor exceptions.
- **Approval-safe changes:** sensitive updates create proposed versions and restart approval; previously approved versions remain in force while valid.
- **Explainable state:** separate review status, validity status, change status and operational authorization; show why something is blocked.
- **Auditability:** who did what, when, on which version, under which authorization and with which decision.
- **Configuration over one-off code:** scoped custom fields, templates, rules and workflows are versioned and controlled.
- **Modularity and stability:** pages consist of reusable, separately editable components; do not change unrelated features in a release.

## User groups
Platform administrators/support (limited, audited access); client organization administrators; client reviewers and approvers; procurement/operations/compliance teams; supplier organization administrators; supplier contributors/personnel managers; reporting consumers; authorized integration workers.

## Main functional modules
1. Organizations and Suppliers — hierarchy, locations, supplier registry, client–supplier relationships and engagements.
2. Personnel Management — supplier-owned personnel, roles, engagements, location assignments and evidence.
3. Documents and Compliance — versioned files, requirement templates, exceptions, assessments, expiry and controlled reuse.
4. Workflows and Approvals — configurable stages, reviewer rules, delegation, reassignment, escalation and decisions.
5. Contracts Management — legal agreements, parties, amendments, effective terms, obligations, milestones and financial terms.
6. Users and Security — authentication, memberships, scoped permissions and supplier/client access grants.
7. Dashboard and Reporting — metrics, compliance trends, workflow queues, historical snapshots, reconciliation and exports.
8. Administration — versioned organization configuration, forms, fields, notifications, audit, retention and integrations.

## Important boundaries
- Supplier legal identity is shared; client relationship approval is **not** shared.
- Personnel records are supplier-scoped; verified cross-supplier links do not automatically share sensitive information.
- A document version can be shared with consent; its approval does not automatically transfer between clients.
- Contract obligations and compliance requirements can be linked, but each has independent outcomes.
- Parent organization membership does not grant automatic access to all subsidiaries or locations.
- Platform administrators have no automatic blanket access to client confidential content.

## Scope not yet approved
No commitment has been made to accounting/ERP replacement, payments, fleet routing, parent portals, marketplace bidding, AI-driven auto-approval, e-signature provider, or a mobile-native application. These should not be added without explicit scope decisions.

## Delivery guideline
Agree on feature contract and acceptance tests before code. Work on one module or reusable component at a time. Present changes and regression impact. No unrequested redesign, cross-module behavior changes or deployment.
