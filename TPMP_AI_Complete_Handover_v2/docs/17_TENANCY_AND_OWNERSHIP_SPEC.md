# Tenancy and Ownership Specification — DRAFT

**Status: PROPOSED, not approved.** Required by D-23 (`16_DECISION_AMENDMENTS.md`). Written to answer review finding C1. Every table class, predicate and mapping below needs owner review; unknowns are marked OPEN. Nothing here is implemented.

## Problem
Clients are tenants, but suppliers, supplier personnel and supplier documents live in a global registry used by many clients, and one user may belong to several organizations. Without an explicit owner per row, RLS, audit streams and composite foreign keys cannot be designed consistently (`03`, `07` "Cross-tenant integrity", open item 4).

## Proposed organization model
- Every legal entity that logs in or is a party — client or supplier — is a row in `platform.organizations`, distinguished by `organization_capabilities` (`client`, `supplier`; an entity may hold both). PROPOSED.
- `registry.suppliers` holds the shared supplier identity. Each supplier organization links to **at most one** registry identity, and each registry identity to at most one supplier organization (one-to-one, nullable). A registry identity with no linked organization is a **stub**: created by a client, not yet claimed. PROPOSED.

## Ownership classes
| Class | Examples | Owner key | Read predicate (pattern) | Write path |
|---|---|---|---|---|
| Platform-global | roles, permissions, service categories, personnel roles | none | any authenticated user, subject to table purpose | platform operators via audited commands |
| Client-owned | relationships, engagements, requirement assignments, assessments, workflow instances, approved profile snapshots, internal notes | `client_org_id` | membership + scope in that client; never visible to supplier or other clients unless a specific grant says so | D-22 commands |
| Supplier-owned | supplier profile versions, personnel and their profile versions, documents and document versions | `supplier_org_id` | supplier membership + supplier role; client access only via a relationship-scoped grant (D-16) and, for documents, a share (D-08) | D-22 commands |
| Relationship-scoped | access grants, invitations, document shares, adoption records | `(client_org_id, supplier_org_id)` | either side's authorized members, limited to the fields each side may see | D-22 commands |
| Shared registry | supplier identity, identifiers, names | none (stub creator recorded) | minimal public identity fields only; identifiers visible per matching policy | reviewed commands |

## Rules
1. **Composite tenant keys:** client-owned and relationship-scoped child tables carry the owner key and reference parents with composite foreign keys that include it, so a row cannot reference a parent in another tenant.
2. **Stub suppliers:** a client may create a stub with minimum identity fields. Client-entered data about the stub is **client-owned** and is never copied into the shared profile. When the supplier registers, a **claim** flow verifies ownership; claim never exposes client-owned data to the supplier. OPEN: verification method.
3. **Audit streams:** events belong to `tenant:<client_org_id>` or `tenant:<supplier_org_id>` according to the owner key of the affected row; relationship-scoped events are written to both. Platform-only events use `platform`. OPEN: confirm.
4. **Users:** a user's authority is membership in an organization plus explicit scopes (D-01, D-15); a user acting for a supplier cannot read client-owned rows, and vice versa, regardless of shared supplier identity.
5. **Platform operators:** no read access to client-owned or supplier-owned content (`05`); emergency access is separate, time-bound and audited. OPEN: break-glass design.
6. **Merge of supplier identities (D-02):** a merge never moves client-owned rows between clients; it only re-points registry identity references after review.

## Deliverables still required before F1 SQL
- Table-by-table ownership classification for every table in `03`.
- RLS predicate patterns and index requirements per class.
- Negative-test list per class (cross-client, supplier-vs-client, stub, merge).
- Resolution of every OPEN above.
