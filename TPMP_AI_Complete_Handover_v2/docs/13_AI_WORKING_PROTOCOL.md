# AI Coding Agent Operating Protocol

## Inputs and source precedence
- Permanent project docs are read before a task; user-approved task file is the only work authorization.
- Original discussions are supporting evidence; approved numbered decisions govern conflicts unless explicitly amended.
- Unspecified UI, field, workflow and technical details are open questions, not permission to improvise.

## Required execution stages
1. **Discover:** inspect current repository, tests and relevant module documentation.
2. **Scope:** quote task ID, approved requirements, unchanged behavior and exclusions.
3. **Plan:** exact files/tables/API/components affected; dependency and RLS impact; migration/test strategy.
4. **Approval gate:** wait for user approval before code edits.
5. **Implement:** dedicated branch, smallest reversible change, no unrelated refactors.
6. **Verify:** positive and negative auth tests, tenant isolation, versioning, concurrency, regression; record actual command/results.
7. **Report:** diff summary, tests, unresolved issues, risk, status. Do not equate generated files with tested deployment.
8. **Release:** separate approval for merge and production deployment.

## Change governance
A numbered decision can change only with explicit user approval and an amendment recording previous rule, new rule, rationale, affected schemas/modules, migration/compatibility impact, test evidence and approval date.

## Security stop conditions
Stop if a task appears to require leaking client data, bypassing RLS, granting unscoped service credentials, changing immutable approved versions, or altering another module's authoritative state.
