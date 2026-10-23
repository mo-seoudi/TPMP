# Open Questions, Risks and Change Log

## Open decisions — do not assume approved
1. Product name/branding, final navigation, design tokens and exact screen layouts.
2. Commercial SaaS plans, pricing, onboarding model, regions and jurisdictional data-residency requirements.
3. Exact legal retention durations, privacy notices, lawful basis and legal-hold authorities.
4. Physical tenant composite-FK pattern (ownership classes now required by D-23; see `17`) and complete permission/resource matrix for every table.
5. Canonical audit serialization, external checkpoint provider, signing keys and chain rotation schedule.
6. Identity verification and authorization design for privileged backend functions and workers. (Direction: D-22; worker path and API runtime still OPEN.)
7. Organization-level configuration UI, final workflow designer capabilities and module API shapes.
8. Initial release MVP scope, performance SLOs, tenant scale assumptions, disaster recovery objectives and external integrations.
9. Exact status vocabularies and approved field-level sensitivity defaults.
10. F0 SQL review and disposable database test results.

## Additional open items (review 2026-10-23) — all OPEN, not approved
11. Data residency, target markets and Supabase region (blocks any environment with real personal data).
12. File-upload security: malware scanning, allowed types and size limits.
13. MFA and SSO policy (SAML/OIDC) for client organizations.
14. Backup, point-in-time recovery and disaster-recovery objectives; backup handling under erasure.
15. Search requirements (the original project goal listed search among its top priorities; no later spec covers it).
16. Data import and migration tooling for existing supplier data.
17. Tenant offboarding, data export and data-subject access/erasure requests for personnel PII.
18. Email/notification provider and delivery requirements.
19. Billing and subscription model (see item 2).
20. Observability, error tracking and operational monitoring.
21. Localization and RTL support; accessibility standard.
22. External API and webhook requirements.
23. Supplier stub claim and ownership-verification method (`17`).
24. Break-glass/emergency platform access design.

## Risks to monitor
- Global supplier reuse causing cross-client leaks.
- Inadvertent authorization inheritance through hierarchy changes.
- Proposed changes overwriting approved current state.
- Document evidence expiry hidden by pending replacements.
- Database superuser rewriting unanchored audit hashes.
- Cryptographic erasure that fails to remove plaintext backups.
- Worker privilege escalation or duplicate external effects.
- Report aggregates leaking restricted tenant/personnel information.
- Cross-module migrations changing unrelated features.

## Change request template
**Decision/requirement reference:**
**Current approved behavior:**
**Proposed change:**
**Why:**
**Affected modules/tables/components:**
**Security, migration and reporting impacts:**
**Acceptance and regression tests:**
**Approval status and date:**

## Change log
- 2026-10-23 — Branch `claude-v1.0`: amendments A-01…A-05 and decisions D-22…D-24 recorded in `16`; draft tenancy specification `17`; roadmap `09` revised; numbering convention P-xx/D-xx adopted; F0 findings added to `08`/`14`; items 11–24 added. Direction approved by owner; wording pending review; no deployment.
- 2026-10-23 — Reference library v1.0 created, consolidating approved decisions 01–21 and F0 review-only implementation handoff. No additional architecture decision adopted by creating this library.
- 2026-10-24 — Branch `claude-v1.0`: revised F0 migrations and SQL tests (A-01, D-22); original F0 `claim_messages` defect recorded (found by execution); application shell, CI workflow and Vercel config added. App build and tests not yet verified; see `14`.
