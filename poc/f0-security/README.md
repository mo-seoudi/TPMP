# F0 — Authenticated tenant boundary POC

This directory contains **actual first-pass SQL code** for a narrowly scoped, disposable Supabase security experiment. It is not the F0 production migration and does not replace the existing F0 audit/outbox review ZIP.

## Threat model
A malicious authenticated client may alter request bodies, choose arbitrary organization IDs, invoke exposed REST endpoints directly, or claim to be an admin. Database RLS must reject access without active membership. Supabase Auth JWT validation must occur in the trusted gateway; browser-supplied actor IDs must never be trusted.

## Implementation scope
- Minimal organizations, memberships, and tenant-owned note fixture.
- Default-deny RLS with only self-membership visibility.
- Tenant note read and insert permitted only for active members, with `created_by = auth.uid()`.
- No client membership mutation and no blanket platform admin bypass.

## Execution prerequisites (not yet fulfilled)
1. Create a separate disposable Supabase development project with no production data.
2. Review SQL and confirm Postgres role ownership, `auth.uid()`, `auth.users`, and schema exposure. **Do not add `tpmp_poc` to exposed API schemas without explicit review.**
3. Execute SQL with migration credentials only in that disposable environment.
4. Provision two test organizations, two users and memberships using trusted admin tooling; do not commit credentials or JWTs.
5. Exercise the REST API with real verified user JWTs and the negative cases in `002_rls_test_plan.md`.
6. Inspect effective grants, function privileges and RLS. Capture command outputs and CI evidence.
7. Tear down the disposable schema/project after the test.

## Critical limitation
The SQL demonstrates **membership isolation**, not the complete approved authorization system. It lacks role permissions, hierarchical access scopes, versioned grants, supplier relationship grants, protected API commands, audit/outbox, checkpoint custody, invitation flow, and integration tests. Never label this POC production ready.

## Next implementation slice after passing
Trusted API identity and organization context POC; privileged command execution and audit/outbox atomicity; explicit permission checks; test harness and CI; then reviewable Supabase migrations.
