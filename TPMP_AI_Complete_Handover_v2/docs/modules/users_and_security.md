# Users & Security — Module Contract (Architecture Baseline)
**Status:** Architecture approved; detailed functional/UI/API specification not yet approved. **Decision references:** 01,14,15,16,20.

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


## Approved school/group and supplier-user access behavior — 28 October 2026
- A user may be assigned to one school, explicitly selected multiple schools, or a group role with explicitly scoped school grants. Group membership never automatically grants all child-school access.
- The active school/workspace must be prominently visible. Switching workspace changes data context, available actions and approval queues; server authorization is checked for every operation, not just UI navigation.
- School-side authorized administrators may create and edit permitted supplier details and upload/replace supplier and employee documents on behalf of suppliers. Record actor, acting organization, supplier, target school, version and approval outcome.
- Supplier users have their own identities and supplier membership. A school or authorized group administrator invites a named supplier user and grants relationship-specific access and actions. A supplier user can have access to multiple schools through separate explicit grants.
- Supplier users cannot self-grant school access, see unrelated school records, or bypass school-specific compliance decisions. Supplier self-service does not imply full bilateral partnership management.
- Shared company-profile editing and school-specific relationship editing are distinct permissions. Sensitive changes create proposed versions and retain previously approved snapshots until approval.
- Revocation immediately removes effective access to the affected school without necessarily removing the supplier user's access to other authorized schools.
- Exact permission matrix, invitation UX and grant-administration API remain implementation details to specify and test.
