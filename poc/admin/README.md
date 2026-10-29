# Admin PostgreSQL foundation — isolated prototype
File: `001_admin_access_foundation.sql`
Status: committed for review only. **Not executed or validated in PostgreSQL/Supabase. Do not apply to production.**

This draft creates a separate `tpmp_admin_poc` schema rather than altering the approved F0/F1 tables. It models users (linked to Supabase Auth), organizations, memberships, roles, permissions, explicitly scoped school grants, supplier relationships and supplier-user access. All tables have RLS enabled with no client policies or grants: browser access is intentionally denied.

## Known blockers before any execution
- SQL syntax and migration/reset tests have not been run against Supabase.
- Enforce organization kind (school vs supplier), parent hierarchy cycle prevention, role-owner and membership-owner integrity, and matching supplier membership to supplier relationship. FKs in this prototype do **not** yet establish all of those invariants.
- Integrate with actual F0/F1 schema rather than deploying parallel production tables.
- Implement trusted invite/grant/revoke commands with verified identity, delegation checks, optimistic concurrency, immutable audit and transactional outbox.
- Implement authenticated, scope-checked read APIs and safe RLS policies; current default-deny design intentionally exposes no app functionality.
- Determine and test exact role-permission matrix and supplier grants.
- Test negative cross-school, cross-supplier, privilege escalation, revocation and direct API bypass cases.

## Next step
Review and test this isolated schema in a disposable Supabase dev project, then design the actual dependency-ordered migration against verified F0/F1 schema. No deployment without explicit approval.
