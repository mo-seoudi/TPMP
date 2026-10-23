# TPMP — Master Reference Library
**Baseline:** v1.0 | **Date:** 23 October 2026 | **Status:** Architecture reference; implementation pending

## Purpose
This library is the pre-build source of reference for the independent **Third-Party Management Platform (TPMP)**: its scope, decisions, user experiences, data architecture, security, delivery principles and open implementation work. It consolidates decisions discussed and accepted in the TPMP project, rather than reproducing every chat message verbatim.

## Authority and change control
- **Approved:** A numbered decision recorded in `02_DECISION_REGISTER.md` or an explicitly agreed requirement. Preserve it until the user approves a replacement.
- **Proposed:** A suggested technical implementation or UX pattern. Do not treat as approved product behavior.
- **Open:** Not yet resolved; do not silently invent a permanent rule.
- When design notes conflict, an explicit approved decision takes precedence; record the conflict and seek approval.
- The F0 SQL archive is **review-only and untested**, not proof that the full specification has been implemented.

## Read in this order
1. `01_PRODUCT_CHARTER_AND_SCOPE.md` — purpose, audience, capabilities, exclusions.
2. `02_DECISION_REGISTER.md` — all 21 accepted core data-model decisions and 16 foundational principles.
3. `03_DOMAIN_MODEL_AND_RELATIONSHIPS.md` — entities, boundaries and core flows.
4. `04_WORKFLOWS_COMPLIANCE_AND_DOCUMENTS.md` — operational rules and versioning.
5. `05_SECURITY_PRIVACY_AND_GOVERNANCE.md` — access, audit, retention and tenant isolation.
6. `06_UI_UX_AND_MODULE_CONTRACTS.md` — product experience and reusable components.
7. `07_DATABASE_AND_DEPLOYMENT_STRATEGY.md` — physical PostgreSQL, migrations and CI/CD.
8. `08_F0_FOUNDATION_IMPLEMENTATION.md` — audit/outbox baseline and gaps.
9. `09_BUILD_ROADMAP_AND_ACCEPTANCE.md` — sequenced build plan and tests.
10. `10_OPEN_QUESTIONS_AND_CHANGE_LOG.md` — unresolved choices and decision process.
11. `16_DECISION_AMENDMENTS.md` — amendments A-01…A-05 and new decisions D-22…D-24 (2026-10-23; wording pending owner review). Read with `02`/`11`.
12. `17_TENANCY_AND_OWNERSHIP_SPEC.md` — DRAFT ownership classes (PROPOSED).

## Project workstreams
00 Project Hub; 01 Architecture & Data Model; 02 UI/UX & Design System; 03 Organizations & Suppliers; 04 Personnel Management; 05 Documents & Compliance; 06 Workflows & Approvals; 07 Contracts Management; 08 Users & Security; 09 Dashboard & Reporting; 10 Development & Deployment.

## Baseline technology
React + TypeScript frontend; Supabase PostgreSQL, Auth and private Storage; Vercel hosting; GitHub version control. A modular monolith, not microservices. One shared multi-tenant PostgreSQL database **per environment** with RLS and logical schemas.
