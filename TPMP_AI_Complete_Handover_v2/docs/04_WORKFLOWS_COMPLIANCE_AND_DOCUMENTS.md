# Operational Rules: Compliance, Documents, Approvals and Contracts

## Requirement lifecycle
1. Define versioned requirements and reusable category/role templates.
2. Assign requirements automatically to the correct compliance subject when relationships, engagements, locations or personnel assignments are created or changed.
3. Allow authorized client admins to add, modify, waive or remove individual requirements, with reasons, approval rules and audit.
4. Preview impact before applying template changes to existing relationships; controlled propagation, not silent mass rewriting.
5. Request evidence, assess coverage and validity, issue client-specific approval and monitor expiry.
6. Keep review status, validity status, change status and operational authorization separate.

## Supplier and personnel changes
Supplier users can edit their permitted company details, personnel records and documents. Sensitive edits default to a new submitted version and client review. Organizations may require approval for every change or allow low-risk fields to update without review. The currently approved version remains effective until an approved replacement activates, subject to its own validity/expiry. Track before/after versions, actor, timestamp, decision and reason. Personnel assignment changes may require pre-activation compliance checks and operational gates.

## Evidence reuse
Reuse approval only within the same client when requirement equivalence, immutable document version, covered scope, validity and client policy match. Each assignment retains an independent assessment and audit trail. Never reuse one client's approval automatically for another client.

## Document lifecycle and sharing
Document identity is distinct from immutable file versions. Pending replacement is not effective evidence and never extends an expired version. Sharing may be document-level or version-specific; future versions require policy/consent. Explicit version restrictions override general sharing. Revocation blocks future unauthorized access but does not erase protected prior decisions or legal holds. Store file bytes privately; use scoped grants and expiring signed URLs as appropriate.

## Workflow engine
Versioned workflow definitions and client bindings; pinned version per running instance. Configurable stages, conditions, reviewer eligibility, parallel/serial decisions, rework, approvals and rejection. Recheck reviewer authority at task assignment and decision. Support segregation of duties, authorized time-bound delegation, reassignment and escalation; avoid circular delegation. Append-only decisions; module-specific activation occurs only after workflow success and business gates.

## Contracts
Original signed documents and amendments remain immutable. Effective operational terms are versioned projections with provenance to legal sources, effective dates, supersession and reviewed ambiguities. Track parties, engagements, obligations, occurrences, performance, milestones and financial terms. Contract obligations and compliance requirements may be explicitly mapped, but approvals and status remain separate.

## Notifications and automation
Domain transaction writes outbox event atomically; worker delivers at least once with idempotent consumer processing. Configurable notification rules, due-date checks, escalations and retry/dead-letter handling. No reliance on an email send as proof a database transaction succeeded.

## Example: document replacement
Supplier uploads v2 -> submitted -> workflow pending -> v1 remains effective while valid -> reviewers approve v2 -> effective-date and coverage checks -> v2 activated -> v1 preserved as historical evidence -> downstream assessments reevaluated as needed. If v1 expires before v2 approval, requirement may become unsatisfied; pending v2 does not prevent expiry.
