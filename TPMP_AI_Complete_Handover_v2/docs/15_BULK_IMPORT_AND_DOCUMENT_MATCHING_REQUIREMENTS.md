# TPMP — Bulk Data Import, Document Upload & Record Association
**Requirement:** TPMP-FR-IMPORT-001  
**Status:** Approved functional scope, not implemented  
**Priority:** MVP / high  
**Approved:** 28 October 2026  
**Scope:** Shared import service across supplier, personnel, documents/compliance, security and workflow modules.

## 1. Objective
Enable authorized client and supplier users to register and update many personnel records in one controlled operation using Excel (.xlsx) or CSV, together with bulk document uploads. A spreadsheet may reference uploaded filenames or existing TPMP document references so the system associates each file with the correct supplier, personnel profile, and document/compliance requirement. Avoid repetitive manual entry. This is an **in-app supplier repository**, not merely an export or external file store.

## 2. Approved MVP capabilities
1. Download an import template generated from the applicable supplier category, personnel roles, approved standard fields, and configured custom fields. Templates identify required fields, data types and permitted document types.
2. Import Excel/CSV containing multiple personnel; create **and update** existing profiles.
3. Map spreadsheet headers to standard/custom fields; allow reusable mapping presets where authorized.
4. Match existing employees by a stable **supplier-scoped employee identifier**. Never silently merge personnel across suppliers or client organizations.
5. Upload multiple files or a ZIP archive to private staging storage, then associate files using exact filename or existing repository document reference.
6. Associate documents with the correct supplier, employee, document type and applicable requirement assignment; maintain virtual folders/metadata rather than assuming physical directory names determine access.
7. Validate data types, mandatory fields, duplicate identifiers, conflicting existing values, expiry dates, document references, ambiguous/duplicate filenames, missing documents, invalid file types and authorization.
8. Preview planned **create / update / skip / reject** outcomes, field differences, matched/unmatched documents, and approvals required **before any commit**. User explicitly confirms execution.
9. Provide row/file-level error reports, corrections, safe partial import of valid records when explicitly selected, and idempotent retry/resume without duplicate records or versions.
10. Record uploader, supplier/tenant scope, batch ID, source file references, decisions, affected records, outcomes, and correlation IDs in the audit trail.
11. Apply existing requirement templates and client-specific compliance rules; uploaded documents are **not automatically approved**.
12. Apply existing field-level approval, immutable versioning and assignment rules. Previously approved profiles remain effective while proposed changes await review. Imported personnel identities do not automatically become authorized for a client's worksite.

## 3. Guided user journey
1. Authorized user opens Supplier Repository > Bulk Import / Update.
2. Selects supplier, import type, relevant personnel roles and, where applicable, client engagement.
3. Downloads a generated spreadsheet template or uploads an existing Excel/CSV file.
4. Uploads documents in bulk (multiple files or ZIP) or selects eligible existing repository references.
5. Maps columns and document-reference columns to defined fields and requirement types.
6. Runs preflight validation and document matching.
7. Reviews summary and row-by-row create/update/skip/reject results, conflicts and approval impacts.
8. Corrects errors, selects permitted partial processing if needed, and explicitly confirms.
9. System stages and executes authorized operations, preserving module-owned transactions, version histories and audit events.
10. User receives an import report with created/updated profiles, pending approvals, unmatched files and errors; can retry safely.

## 4. Example template (illustrative only)
| Employee ID | Full Name | Role | Licence Expiry | Driving Licence File | RTA Permit File |
|---|---|---|---|---|---|
| DRV001 | Ahmed Ali | Driver | 2027-06-15 | DRV001_DL.pdf | DRV001_RTA.pdf |
| DRV002 | Omar Hassan | Driver | 2027-09-22 | DRV002_DL.pdf | DRV002_RTA.pdf |

Names, dates, roles and requirements above are illustrative; actual required fields derive from the client/supplier/role configuration.

## 5. Matching and validation rules
- Prefer stable supplier-scoped employee ID; missing or ambiguous IDs require correction or explicit authorized resolution.
- Exact file-reference matching is deterministic and case/normalization behavior must be documented; duplicate names are ambiguous unless disambiguated by a unique staged-file reference.
- Never silently associate uncertain files with a person, supplier or requirement.
- An uploaded document is a new immutable document version or document record, with independent client-specific evidence assessment.
- An import does not override client-specific grants, legal holds, document version sharing, or requirement exceptions.
- Validate ZIP extraction paths, decompression size limits, malware scans, MIME/extension checks, file limits and private storage authorization.
- Treat spreadsheet contents as untrusted input; do not execute formulas, links, macros or embedded code. Restrict imported external URLs and prevent spreadsheet formula injection in generated reports.

## 6. Security, processing and architecture
- Implement as a reusable **shared import service** with module-specific validation/commit adapters, not independent ad hoc import logic for each module.
- Import permissions are supplier/relationship/resource scoped and checked on preview **and again on commit**; trusted server identity and RLS are mandatory.
- Use staging records and private document storage; define cleanup/retention of uploaded originals and rejected files.
- Large batches run asynchronously through controlled jobs with progress, retry, per-row outcomes, concurrency control and idempotency keys.
- Use transactional outbox/audit infrastructure as applicable; never imply a single database transaction can atomically commit arbitrary external object-store operations.
- Prevent cross-tenant file exposure and cross-supplier personnel identity merging.

## 7. Module ownership
- **03 Organizations & Suppliers:** supplier repository, supplier scope, onboarding entry point.
- **04 Personnel Management:** employee fields, create/update, stable identifiers, assignment proposals.
- **05 Documents & Compliance:** private document vault, versions, requirement association and evidence status.
- **06 Workflows & Approvals:** proposed changes, reviewer decisions, preserved approved state.
- **08 Users & Security:** import permissions, grants, trusted context and audit.
- **02 UI/UX:** import wizard, mapping, validation preview and result reporting.
- **10 Development & Deployment:** shared infrastructure, tests and operational processing.

## 8. Acceptance criteria
- A single spreadsheet can create multiple correctly scoped personnel profiles.
- A subsequent spreadsheet can update matching profiles without creating duplicates.
- Pre-commit preview clearly identifies creates, updates, skips, rejects, changed fields, file matches and approval impacts.
- Multiple uploaded files can be linked to the intended supplier/personnel/requirement using unique filenames or repository references.
- Missing, ambiguous, duplicated or unauthorized matches are blocked or explicitly reported; never silently guessed.
- Re-importing a previously successful batch does not duplicate profiles, documents, assignments or approvals.
- Approved data remains effective until pending changes are approved and activated under existing policies.
- Client-specific compliance assessments remain independent; uploaded evidence is not auto-approved.
- Unauthorized or cross-tenant imports fail; audit and import-result reports are traceable.
- Partial failures can be recovered safely with row-level outcomes.

## 9. Deferred (not MVP)
Direct SharePoint/OneDrive ingestion, scheduled synchronization, OCR-assisted classification, automatic extraction from documents, and uncontrolled external-link fetching.

## 10. Implementation status and outstanding detailed design
**Approved requirement only; no code, migration, UI or deployment has been implemented by this document.**
Before implementation, specify import staging tables, job states, batch/row identity and retention, precise role-based permission matrix, spreadsheet schema and column types, duplicate resolution policy, document reference syntax, upload limits, transaction/compensation strategy, and executable acceptance/security tests. These are implementation details, **not** permission to weaken previously approved architecture decisions D01–D21.
