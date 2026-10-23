# Expanded Approved Architecture and Core Data Model Decisions
**Authority:** This expands the approved outcomes in `02_DECISION_REGISTER.md`. Option C was explicitly approved for every Core Data Model decision 01–21. These are architectural contracts, not proof that the tables exist.

## Foundational architecture decisions (01–16)
1. **Shared supplier identity:** one reusable supplier identity across independent clients; relationship/compliance decisions always isolated.
2. **Hybrid supplier profile ownership:** supplier-maintained shared data and independent client adoption/approval snapshots.
3. **Personnel ownership:** personnel scoped to supplier, with client-specific assignments and compliance; document sharing controlled.
4. **Requirements:** reusable category/role templates automatically assign requirements; authorized admins add, modify, waive or remove requirements per supplier/engagement; preview propagation impact.
5. **Approval:** configurable multistage and field/document-level rules; preserve prior approved version; separate review, validity and change statuses; audit every decision.
6. **Identity/security:** Supabase Auth; one user can belong to multiple organizations; hybrid RBAC plus explicit scopes; tenant RLS and server-side authorization; platform admin no blanket client data access.
7. **Documents:** private Supabase Storage, immutable document versions, metadata-driven virtual folders, controlled shares.
8. **Lifecycle:** configurable retention, archival, anonymization, deletion, legal holds and protected audit.
9. **Automation:** transactional domain events/outbox, notifications, scheduled checks, escalation, idempotency, retries.
10. **Contracts:** relationships, legal parties, amendments, effective terms, obligations, milestones, financial terms.
11. **Configuration:** typed protected core fields plus validated, versioned custom forms/fields, conditional visibility, validation and approval policies.
12. **Configuration governance:** draft, preview, validate, optionally approve, schedule activation; version configuration; impact preview, propagation and rollback safeguards.
13. **Database:** shared Supabase PostgreSQL with logical schema separation and tenant RLS.
14. **Application:** modular monolith, typed APIs, reusable components, controlled dependencies and regression tests.
15. **Delivery:** isolated dev/staging/prod, GitHub, Vercel previews, CI/CD, migrations, controlled releases and approval.
16. **Working method:** specification-first, implement independently scoped modules/components, no unrequested modifications.

## Core Data Model decisions — expanded implementation contracts
### Decision 01 — Organization hierarchy and membership (Option C, approved)
**Required behavior:** Legal entities, configurable hierarchy, operating units and locations; explicit memberships and access scopes; group/parent membership never automatically authorizes subsidiary records.

**Named tables/structures:** `platform.organizations; organization_hierarchy; operating_units; locations; membership_scopes; organization_capabilities; user_profiles; organization_memberships; registry.suppliers; tenant.supplier_relationships`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 02 — Supplier identity matching (Option C, approved)
**Required behavior:** Jurisdiction-aware identifiers, matching candidates, verified reviewed merges, alias/name history; never silently merge client-specific records or relationships.

**Named tables/structures:** `registry.supplier_identifiers; supplier_identity_candidates; supplier_identity_reviews; supplier_identity_merges; supplier_names`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 03 — Shared supplier profiles and adoption (Option C, approved)
**Required behavior:** Versioned shared supplier profiles, immutable submissions, field-level decisions and provenance; each client independently adopts and approves snapshots. Approved current state remains during review.

**Named tables/structures:** `registry.supplier_profile_versions; supplier_profile_changes; tenant.supplier_profile_adoptions; supplier_field_decisions; supplier_approved_profiles; supplier_profile_current`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 04 — Typed relational core and JSONB (Option C, approved)
**Required behavior:** Stable identifiers and critical relationships relational and typed; configurable field definitions relational; validated JSONB only for versioned configurable fields/snapshots, not universal generic entity storage.

**Named tables/structures:** `Core typed entities; versioned field definitions; validated JSONB snapshots`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 05 — Compliance assignment granularity (Option C, approved)
**Required behavior:** Requirements attach to supplier relationship, engagement, engagement-specific location and personnel assignment. Versioned category/role templates, deduplication and authorized exceptions; impact-controlled propagation.

**Named tables/structures:** `tenant.supplier_engagements; platform.service_categories; tenant.engagement_categories; engagement_locations; compliance.requirement_definitions; requirement_definition_versions; requirement_templates; requirement_template_versions; template_requirement_items; compliance_subjects; requirement_assignments; requirement_exceptions`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 06 — Evidence assessment reuse (Option C, approved)
**Required behavior:** Within-client controlled reuse only if exact immutable document version, equivalent criteria, coverage, validity and policy allow; independent assignment outcome and audit; no automatic cross-client approval transfer.

**Named tables/structures:** `compliance.evidence_assessments; evidence_assessment_criteria; evidence_approval_reuses; requirement_assessments; evidence_validity_events; evidence_links; requirement_assessment_evidence`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 07 — Document evidence lifecycle (Option C, approved)
**Required behavior:** Immutable document versions, private storage keys, staged upload/reconciliation, effective evidence intervals; previous approved version remains only while valid; pending replacement cannot extend expiry.

**Named tables/structures:** `documents.documents; document_versions; document_version_metadata; document_shares; document_version_transitions; compliance.effective_evidence`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 08 — Document sharing (Option C, approved)
**Required behavior:** Document-level and version-level grants; explicit future-version consent, version restrictions override broad grants, revocation prevents future unauthorized access but does not erase protected historical decisions.

**Named tables/structures:** `documents.document_share_policies; document_version_grants; document_access_events; document_access_projections`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 09 — Personnel identity (Option C, approved)
**Required behavior:** Supplier-scoped personnel records; optional verified cross-supplier linking only after controlled review; never silently merge or share sensitive personnel data, evidence or client approvals.

**Named tables/structures:** `registry.personnel; personnel_profile_versions; identity.personnel_link_cases; personnel_link_verifications; personnel_identity_links; personnel_link_access_events`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 10 — Personnel assignment lifecycle (Option C, approved)
**Required behavior:** Versioned proposed assignments, reviewer cases, impact reviews, activation checks and effective pointers. Approval may precede activation; compliance gates can block authorization; activation transactional, optimistic concurrency; supplier change means new identity/assignment.

**Named tables/structures:** `tenant.personnel_assignments; personnel_assignment_locations; personnel_approved_profiles; personnel_assignment_versions; personnel_assignment_proposals; personnel_assignment_approval_cases; personnel_assignment_impact_reviews; personnel_assignment_activation_checks; personnel_assignment_current; personnel_assignment_events; platform.personnel_roles`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 11 — Contracts and effective terms (Option C, approved)
**Required behavior:** Original agreements and amendments immutable; consolidated operational effective-term snapshots versioned with source provenance, dates and supersession; legal ambiguity reviewed, not silently overwritten. Obligations, milestones and financial terms separately versioned.

**Named tables/structures:** `contracts.agreements; agreement_parties; agreement_engagements; agreement_versions; agreement_amendments; agreement_term_definitions; agreement_term_revisions; agreement_effective_snapshots; effective_snapshot_terms; agreement_effective_current; contract_obligations; obligation_versions; obligation_occurrences; obligation_performance_events; contract_milestones; contract_milestone_events; financial_term_versions`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 12 — Contract–compliance integration (Option C, approved)
**Required behavior:** Explicit mapping between obligations and requirements, controlled reuse of same immutable evidence with independent assessments; neither module silently rewrites the other’s outcome.

**Named tables/structures:** `integration.contract_compliance_links; contract_compliance_evaluations; contract_compliance_impact_events`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 13 — Shared workflow engine (Option C, approved)
**Required behavior:** Reusable versioned definitions/templates, organization-scoped bindings and reviewer rules, pinned execution versions, append-only decisions, separation of duties, reviewer eligibility at assignment and decision. Engine reviews; owning module activates.

**Named tables/structures:** `workflow.workflow_definitions; workflow_definition_versions; workflow_templates; workflow_template_versions; workflow_definition_sources; workflow_stage_definitions; workflow_stage_transitions; workflow_bindings; workflow_binding_versions; reviewer_assignment_rules; workflow_instances; workflow_stage_instances; workflow_review_tasks; workflow_decisions; automation.domain_events; outbox_messages; notification_rules; notification_deliveries; scheduled_jobs; audit.audit_events`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 14 — Delegation, reassignment and escalation (Option C, approved)
**Required behavior:** Controlled time-limited delegation, authorized reassignment and escalation; grantor cannot delegate authority they lack; delegate needs own eligibility; prevent circular delegation, recheck on decision, revoke immediately, idempotent escalation and full history.

**Named tables/structures:** `workflow.reviewer_delegations; reviewer_delegation_scopes; reviewer_delegation_events; review_task_assignments; review_task_reassignment_events; workflow_escalation_rules; workflow_escalation_events`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 15 — Access scopes and hierarchy (Option C, approved)
**Required behavior:** Explicit typed scope targets; versioned grants, policy-authorized hierarchy expansion, recorded resolutions and impact reviews; new descendants excluded until reviewed; revocation immediate; default-deny RLS, trusted identity, no blanket admin.

**Named tables/structures:** `security.access_scope_definitions; access_scope_versions; access_scope_targets; access_scope_expansion_policies; access_scope_resolutions; access_scope_resolved_targets; access_grant_versions; access_impact_reviews; permissions; roles; role_permissions; user_role_assignments; resource_access_grants; resource_access_events`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 16 — Supplier relationship access (Option C, approved)
**Required behavior:** One supplier user identity with explicit supplier memberships and internal role plus separate client relationship/engagement grant and resource/version checks; supplier admin manages own team but cannot view client private decisions. Hashed invitations, verified acceptance and immediate revocation.

**Named tables/structures:** `security.supplier_relationship_access_grants; supplier_relationship_grant_permissions; supplier_relationship_access_events; supplier_relationship_invitations; supplier_relationship_access_requests`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 17 — Reporting architecture (Option C, approved)
**Required behavior:** Live operational queries plus controlled versioned metric definitions, projection runs with source watermark, historical snapshots, tenant-specific policies, reconciliations, freshness, source provenance; current authorization applies to historical results, prevent aggregate inference.

**Named tables/structures:** `reporting.metric_definitions; metric_definition_versions; organization_metric_policies; projection_definitions; projection_runs; metric_snapshots; projection_reconciliations`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 18 — Temporal conventions (Option C, approved)
**Required behavior:** Module-owned typed immutable version tables, recorded/system versus business-effective time, submitted/approved versus activated, current pointers, supersession, row revision and compare-and-swap; half-open intervals, late/backdated corrections preserve as-known history.

**Named tables/structures:** `uuid identifiers; unique(entity_id, version_number); timestamptz; temporal exclusions where applicable; immutable events; CAS updates`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 19 — Migration strategy (Option C, approved)
**Required behavior:** One coordinated Supabase migration history, dependency-ordered module packages, explicit schema contracts, expand-transition-contract for breaking changes, RLS and compatibility tests, isolated dev/staging/prod, approval gates.

**Named tables/structures:** `F0 foundation → organization/identity/security → relationships → document/compliance foundations → workflows → operational lifecycles → integration/automation → reporting`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 20 — Audit ledger (Option C, approved)
**Required behavior:** Central append-only audit events plus module-specific immutable business history; trusted writes, actor/action/resource/tenant/correlation attribution, integrity verification, privacy minimization, controlled retention, legal holds, privileged access audit.

**Named tables/structures:** `audit.audit_events; audit.integrity_checkpoints; audit.integrity_verification_runs; audit.retention_policies; audit.legal_holds`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.

### Decision 21 — Audit segments and erasure (Option C, approved)
**Required behavior:** Segmented hash chains, serialized per-segment append, sealed terminal hashes and independently protected checkpoints; legal-hold-aware retention; minimize sensitive hashed payloads; documented redaction/cryptographic erasure with protected evidence.

**Named tables/structures:** `audit.audit_segments; audit.audit_events; integrity_checkpoints; integrity_verification_runs; retention_policies; legal_holds; retention_execution_events`.

**Non-negotiable:** Implementation must not silently weaken the rule; any exceptions require explicit decision amendment.
