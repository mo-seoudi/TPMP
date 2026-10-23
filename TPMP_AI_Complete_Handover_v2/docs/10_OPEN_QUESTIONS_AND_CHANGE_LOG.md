# Open Questions, Risks and Change Log

## Open decisions — do not assume approved
1. Product name/branding, final navigation, design tokens and exact screen layouts.
2. Commercial SaaS plans, pricing, onboarding model, regions and jurisdictional data-residency requirements.
3. Exact legal retention durations, privacy notices, lawful basis and legal-hold authorities.
4. Physical tenant composite-FK pattern and complete permission/resource matrix for every table.
5. Canonical audit serialization, external checkpoint provider, signing keys and chain rotation schedule.
6. Identity verification and authorization design for privileged backend functions and workers.
7. Organization-level configuration UI, final workflow designer capabilities and module API shapes.
8. Initial release MVP scope, performance SLOs, tenant scale assumptions, disaster recovery objectives and external integrations.
9. Exact status vocabularies and approved field-level sensitivity defaults.
10. F0 SQL review and disposable database test results.

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
- 2026-10-23 — Reference library v1.0 created, consolidating approved decisions 01–21 and F0 review-only implementation handoff. No additional architecture decision adopted by creating this library.
