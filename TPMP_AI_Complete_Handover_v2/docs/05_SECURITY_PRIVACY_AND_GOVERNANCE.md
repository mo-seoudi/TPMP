# Security, Privacy and Governance Strategy

## Authorization layers
Supabase Auth establishes identity. Membership and scoped roles establish organizational authority. Resource-level grants and RLS enforce tenant boundaries. A supplier user accessing client relationship data must pass supplier membership, supplier role, explicit client relationship/engagement grant and document/resource restrictions. Server-side APIs must enforce the same decisions; UI hiding is not authorization.

## Hierarchy and scopes
`security.access_scope_definitions`, `access_scope_versions`, `access_scope_targets`, `access_scope_expansion_policies`, `access_scope_resolutions`, `access_scope_resolved_targets`, `access_grant_versions`, `access_impact_reviews`, plus `permissions`, `roles`, `role_permissions`, `user_role_assignments`, `resource_access_grants`, `resource_access_events`. Newly added child organizations are excluded until policy/review permits expansion. Revocations take effect immediately.

## Supplier access
`security.supplier_relationship_access_grants`, `supplier_relationship_grant_permissions`, `supplier_relationship_access_events`, `supplier_relationship_invitations`, `supplier_relationship_access_requests`. Supplier admins manage their own people, not a client's internal notes, reviewer decisions or other clients' data. Invitation tokens hashed and acceptance verified.

## Data security
Private storage, per-version access, short-lived download authorization, server-controlled uploads, no direct broad public buckets. Tenant-aware composite FKs and default-deny RLS. Trusted privileged functions use fixed `search_path`, least privilege, verified actor attribution and explicit EXECUTE grants. Service-role credentials never enter the browser.

## Audit
Central `audit.audit_events` append-only ledger plus immutable module histories. Segmented hash chains, transactional ordering and independent protected terminal checkpoints. Store minimum necessary personal data in hashed metadata; independently protected sensitive details can be deleted/erased under policy. Database-only hashes cannot defeat a database superuser who also controls checkpoints; independent custody is required.

## Retention and legal holds
Versioned policies for archive, anonymize, delete, retention and legal holds. Retention execution must be authorized, audited and blocked for held data. Segment-level archival/deletion preferred; granular redaction/cryptographic erasure must not silently invalidate integrity claims. Exact legal periods and jurisdiction rules are not yet defined and require legal review.

## Platform support
Platform admins do not automatically see all tenant documents or personnel. Any emergency access must be purpose-limited, time-bounded, justified, logged and reviewable. Avoid personal-data leakage through reports, aggregate inference, exports, notifications and errors.

## Required security tests
Cross-client reads/writes denied; group-parent membership does not expand implicitly; revoked grant denied immediately; supplier user cannot see other client; unauthorized document version denied; impersonated actor rejected; direct audit mutation denied; workflow SoD enforced; concurrency and RLS tests on all new tables.
