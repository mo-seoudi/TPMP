# TPMP Admin / Users — UI-to-PostgreSQL implementation contract (draft v0.1)
Status: design preparation only; not an approved or executed migration.
Target: Supabase Auth + PostgreSQL; React Administration page.
Scope: user directory, invite, roles, school workspace grants, supplier relationship access, revoke/suspend, access history.

## Data ownership and core entities
Reuse the approved F0/F1 schemas and names; do not create competing identity tables.
- auth.users: authentication identity (Supabase-owned).
- identity.user_profiles: user display metadata keyed by auth user UUID; no password storage.
- platform.organizations: legal entities, school units, supplier organizations; typed parent links are structural only and confer no implicit access.
- security.organization_memberships: user-to-organization membership, state and validity.
- security.permissions, roles, role_permissions: catalog of allowed actions and reusable role definitions.
- security.user_role_assignments: user + role + explicit scope target (organization/school) with validity and revocation.
- security.resource_access_grants: narrow grants when role scope is insufficient.
- registry.suppliers and tenant.supplier_relationships: shared legal supplier identity and separately owned school/client engagements.
- security.supplier_relationship_access_grants: supplier member + explicitly permitted client relationship + actions, with invitation and revocation history.
- security.invitations: hashed single-use token reference, inviter, invitee, scope, expiry, accepted/revoked timestamps; invite acceptance must verify authenticated email/identity.
- audit.audit_events: append-only records for grants, invitations, suspension, document actions and approval changes.

## UI-to-command contract
| UI action | Server command | Mandatory checks |
|---|---|---|
| List users | listAuthorizedUsers(workspaceId) | authenticated caller, explicit scope, least-privilege columns |
| Invite user | inviteUser(email, organizationId, roleId, scopeIds) | inviter has user.invite and grant authority for every target; no self-escalation |
| Change role/school access | updateUserGrants(userId, changes, revision) | grantor can delegate each permission and target; optimistic concurrency |
| Suspend/revoke | revokeAccess(grantId, revision) | authorized actor; immediate effective denial; history retained |
| Supplier invitation | inviteSupplierUser(supplierId, relationshipIds, actions) | supplier/client relation exists; school authority for every relationship |
| Switch workspace | selectWorkspace(workspaceId) | display-only client context; every subsequent API/database operation reauthorizes |

## SQL shape (illustrative, NOT executable migration)
Use existing approved security schema objects and migration order. Example constraints for eventual implementation:
```sql
-- Illustrative only: confirm existing physical schema before migration.
-- security.user_role_assignments:
--   id uuid primary key, user_id uuid not null references auth.users(id),
--   role_id uuid not null, scope_type text not null,
--   scope_target_id uuid not null, valid_from timestamptz not null,
--   valid_to timestamptz, revoked_at timestamptz,
--   check (scope_type in ('organization','school','supplier_relationship')),
--   check (valid_to is null or valid_to > valid_from);
-- Index active grants by (user_id, scope_type, scope_target_id).
-- Enforce scope target existence via typed FK/validated registry; avoid unchecked polymorphic IDs.
-- RLS default deny; no broad browser write grants on authorization tables.
-- Privileged mutations via trusted API/database command boundary with verified auth.uid().
```

## Invariants
1. Role and scope are separate; a person can hold different roles in different schools.
2. Parent/group role never automatically includes child schools.
3. Supplier shared identity is not a permission to access all school relationships.
4. Supplier users may have multiple separately authorized relationships.
5. School admins can edit/upload supplier documents on behalf of suppliers only when permitted, with proposed/approved version separation.
6. Workspace selection is never trusted as proof of authorization.
7. No client data visibility merely from platform super-admin status.
8. Never store invitation plaintext tokens, service-role secrets or passwords in client tables.
9. Grants and revocations are audited; revocation is immediately enforced.
10. Privileged SQL functions must have fixed search_path, minimal EXECUTE grants, verified actor, and protected audit/outbox effects.

## Test plan / acceptance gates
- Same user: school A admin, school B reviewer, school C denied.
- Group-level membership without child grant cannot access child data.
- Supplier user with A+B grants can edit only authorized A+B relationship fields; C denied.
- School admin uploads supplier document; actor and acting school captured; approval preserved.
- Revoked user denied immediately, including direct API/SQL calls.
- Cannot invite/grant a role more privileged than inviter's delegated authority.
- Reject forged actor/workspace IDs, unauthorized role changes, expired/reused invites.
- Audit cannot be edited by ordinary application users.
- Clean migration apply/reset, RLS negative tests, concurrency and UI integration tests.

## Sequence
1. Inspect actual F0 SQL and resolve POC identity/RLS/function ownership before implementing.
2. Finalize role/permission matrix and organization/supplier relationship physical schema.
3. Write dependency-ordered migrations and seed permission catalog.
4. Implement secure invite/grant/revoke API commands and automated tests.
5. Wire Admin Users page and workspace selector to real API; test end-to-end.
6. Deploy only after Supabase dev exists, validation passes and explicit deployment approval.

No database has been created, changed or deployed by this document.
