# Domain Model and Relationships

## Organization and tenancy
`platform.organizations` represents legal entities. `organization_hierarchy`, `operating_units`, `locations`, `organization_capabilities`, `user_profiles`, `organization_memberships`, `membership_scopes` represent structure and explicit access. A group may have subsidiaries, campuses and operating units; membership at a parent does not automatically authorize descendants.

## Shared supplier registry versus client relationships
`registry.suppliers`, `supplier_identifiers`, `supplier_names`, `supplier_identity_candidates`, `supplier_identity_reviews`, `supplier_identity_merges` hold shared identity and reviewed matching. `tenant.supplier_relationships` belongs to a client–supplier relationship. `tenant.supplier_engagements`, `engagement_categories`, `engagement_locations` describe contracted/operational scope. One supplier may serve many clients without revealing one client's confidential information to another.

## Supplier profiles and adoption
`registry.supplier_profile_versions`, `supplier_profile_changes` hold supplier-origin versions. `tenant.supplier_profile_adoptions`, `supplier_field_decisions`, `supplier_approved_profiles`, `supplier_profile_current` hold each client's adoption and approval. A supplier edit is not an automatic overwrite of client-approved values.

## Personnel
`registry.personnel`, `personnel_profile_versions` are supplier-scoped. `identity.personnel_link_cases`, `personnel_link_verifications`, `personnel_identity_links`, `personnel_link_access_events` support controlled cross-supplier linking. `tenant.personnel_assignments`, `personnel_assignment_locations`, `personnel_assignment_versions`, `personnel_assignment_proposals`, `personnel_assignment_approval_cases`, `personnel_assignment_impact_reviews`, `personnel_assignment_activation_checks`, `personnel_assignment_current`, `personnel_assignment_events` support client-specific authorization. `platform.personnel_roles` defines reusable roles.

## Compliance
`compliance.requirement_definitions`, `requirement_definition_versions`, `requirement_templates`, `requirement_template_versions`, `template_requirement_items`, `compliance_subjects`, `requirement_assignments`, `requirement_exceptions`, `requirement_assessments`, `evidence_assessments`, `evidence_assessment_criteria`, `evidence_approval_reuses`, `evidence_validity_events`, `evidence_links`, `requirement_assessment_evidence`, `effective_evidence`. Template assignment is policy-driven, deduplicated and scoped to the right relationship, engagement, location or assignment.

## Documents
`documents.documents`, `document_versions`, `document_version_metadata`, `document_shares`, `document_share_policies`, `document_version_grants`, `document_version_transitions`, `document_access_events`, `document_access_projections`. File bytes reside in private object storage with immutable version keys; metadata and approvals live in PostgreSQL.

## Contracts
`contracts.agreements`, `agreement_parties`, `agreement_engagements`, `agreement_versions`, `agreement_amendments`, `agreement_term_definitions`, `agreement_term_revisions`, `agreement_effective_snapshots`, `effective_snapshot_terms`, `agreement_effective_current`, `contract_obligations`, `obligation_versions`, `obligation_occurrences`, `obligation_performance_events`, `contract_milestones`, `contract_milestone_events`, `financial_term_versions`.

## Workflow and integration
`workflow.workflow_definitions`, `workflow_definition_versions`, `workflow_templates`, `workflow_template_versions`, `workflow_definition_sources`, `workflow_stage_definitions`, `workflow_stage_transitions`, `workflow_bindings`, `workflow_binding_versions`, `reviewer_assignment_rules`, `workflow_instances`, `workflow_stage_instances`, `workflow_review_tasks`, `workflow_decisions`, `reviewer_delegations`, `reviewer_delegation_scopes`, `reviewer_delegation_events`, `review_task_assignments`, `review_task_reassignment_events`, `workflow_escalation_rules`, `workflow_escalation_events`. `integration.contract_compliance_links`, `contract_compliance_evaluations`, `contract_compliance_impact_events` join domains without merging their authority.

## Reporting
`reporting.metric_definitions`, `metric_definition_versions`, `organization_metric_policies`, `projection_definitions`, `projection_runs`, `metric_snapshots`, `projection_reconciliations`. Dimensions include client, unit, supplier, relationship, engagement, location, requirement, document, contract, workflow and period. Historical and current hierarchy attribution must be explicitly distinguished.

## Core relationship narrative
Client organization -> supplier relationship -> engagement -> engagement locations / personnel assignments / compliance subjects. Supplier -> shared profile versions and supplier-scoped personnel. Client -> approved profile snapshot and compliance decisions. Engagements may link to agreements. Agreements have immutable legal versions and operational effective-term projections. Every sensitive change may bind to a workflow and emits protected audit/domain events.

## Physical integrity requirements
Use typed FKs, tenant-aware composite constraints for tenant-owned data, uniqueness, temporal checks, current pointers, optimistic concurrency and RLS. Shared registry tables must not be incorrectly treated as owned by one client. A complete physical FK matrix is still to be generated in later packages.
