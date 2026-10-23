# Decision Amendments and New Decisions — 2026-10-23

**Origin:** Independent architecture review (23 October 2026). The project owner instructed that the reviewer's suggested modifications be applied to the decisions, on branch `claude-v1.0`.
**Status of every entry below: APPROVED IN PRINCIPLE by the project owner on 2026-10-23; exact wording awaits owner review before merge to `main`.** Nothing here is implemented or tested.
**Governance:** Follows `13_AI_WORKING_PROTOCOL.md` (previous rule, new rule, rationale, affected modules, migration impact, test evidence, approval date). Original decision text in `02` and `11` is **preserved unchanged**; each affected decision carries an "Amended by" pointer to this file. Where this file and the original text differ, this file governs for the amended aspect only.
**Principle:** Invariants are kept. Machinery is deferred, not abandoned. A deferral never permits weakening tenant isolation, immutability of approved versions, or audit completeness.

## Numbering convention (resolves review finding C7)
Foundational principles are cited **P-01…P-16**; core data-model decisions **D-01…D-21**; new decisions **D-22 onward**; amendments **A-01 onward**. Bare "Decision 13" is ambiguous and must not be used in new text.

---

## A-01 — Audit integrity phasing (amends D-20, D-21)
- **Previous rule:** Segmented hash chains, serialized per-segment append, sealed terminal hashes and independently protected external checkpoints are part of the F0 foundation.
- **New rule:**
  1. F0 and the MVP ship a **central append-only audit ledger** with module-specific immutable history, trusted writes, actor/action/resource/tenant/correlation attribution, privacy-minimized payloads, **database-level immutability enforcement (triggers denying UPDATE/DELETE outside an audited retention path)**, and canonical event bytes stored at insert.
  2. Hash-chain computation, segment sealing and external checkpoint anchoring are **deferred** to a later phase, gated by the first of: a production tenant holding real personal data under a compliance commitment, or a contractual/certification requirement for tamper evidence. Chain-related columns and the `audit_segments`/`integrity_checkpoints` shapes remain reserved so the later phase is additive.
  3. When chaining is introduced, verification MUST hash the **stored canonical bytes**, not rebuild bytes from `jsonb::text` or timestamp text, and the append path MUST NOT serialize all writes of a tenant (or of the platform stream) on a single row held for the business transaction's duration (e.g. per-shard chains or asynchronous sealing).
  4. Erasure rule unchanged: payloads hold identifiers and minimized data only; personal data lives in separately erasable stores.
- **Rationale:** F0 review found per-tenant write serialization, no operable segment provisioning, fragile re-serialization, and an unbuilt external custody dependency, all before any user story exists.
- **Affected:** `audit.*` F0 migrations; `docs/08`; D-13 outbox/audit coupling.
- **Migration impact:** F0 is unreleased; revise F0.002 in place on the review branch (never edit an applied migration).
- **Test evidence required:** direct UPDATE/DELETE denied for every role incl. event writer; concurrent-append throughput test; later phase adds golden fixtures.

## A-02 — Bitemporal scope (amends D-18)
- **Previous rule:** Standard temporal conventions (recorded vs effective time, version tables, current pointers, CAS) apply to the data model generally.
- **New rule:** Full recorded/effective bitemporal versioning, temporal exclusion constraints and as-known history are **required** for: document versions and evidence validity, supplier-profile adoption versions, personnel assignment versions, requirement-template versions, and contract effective terms. All other entities use `created_at/updated_at`, `row_revision` for optimistic concurrency, and immutable audit/event history. A module may adopt full bitemporality for another entity only by a recorded amendment. Conventions (uuid ids, half-open `[from,to)` intervals, `timestamptz`, naming prefixes) remain mandatory wherever time ranges exist.
- **Rationale:** Cost and complexity of as-known history are justified only where a business rule depends on it.
- **Affected:** all module data contracts; `docs/07` conventions.
- **Migration impact:** none yet (no schema).
- **Tests:** per-entity temporal integrity tests only for the named entities.

## A-03 — Workflow engine phasing (amends D-13, D-14)
- **Previous rule:** Full shared versioned workflow engine, with delegation, reassignment and escalation, delivered with Phase 4.
- **New rule:** The MVP delivers a **minimal approval primitive** (see D-24): one or two serial stages, pinned definition version per instance, reviewer eligibility rechecked at assignment and decision, separation of duties, append-only decisions, owning module activates, outbox events. Definition/version tables are created in the shape D-13 specifies so the full engine is additive. **Delegation, reassignment, escalation, parallel stages and the workflow designer are deferred to Phase 5**; D-14 invariants (grantor cannot delegate authority they lack, no circular delegation, immediate revocation) apply unchanged when built.
- **Rationale:** Roadmap sequencing conflict (review C4) and MVP scope.
- **Affected:** `docs/09`, `modules/workflows_and_approvals.md`.
- **Tests:** SoD and eligibility-at-decision tests in MVP; D-14 tests in Phase 5.

## A-04 — Reporting and configuration governance phasing (amends D-17, P-12)
- **Previous rule:** Hybrid live queries plus versioned metrics, projection runs, snapshots and reconciliation; versioned organization configuration with preview, impact analysis, scheduled activation and rollback.
- **New rule:** MVP uses **live authorized queries only** and **fixed, code-versioned configuration**. Metric/projection/reconciliation machinery and the draft-preview-activate configuration lifecycle are deferred to Phase 5. Invariants apply from the first dashboard: current authorization governs every result; no aggregate or error-message inference of restricted tenant or personnel data; freshness labelled.
- **Affected:** `modules/reporting.md`, `docs/09`.

## A-05 — Identity, reuse and effective-terms staging (amends D-02, D-06, D-09, D-11)
- **Previous rule:** Jurisdiction-aware matching with candidate/merge workflow (D-02); controlled evidence-approval reuse (D-06); verified cross-supplier personnel linking (D-09); consolidated versioned effective-term snapshots (D-11).
- **New rule:** In the MVP: supplier de-duplication is **manual reviewed matching** on normalized identifiers (no automated candidate scoring); **no cross-supplier personnel linking** (D-09 invariants — never silently merge or share — hold by absence of the feature); **no evidence-approval reuse** (each assignment assessed independently); Contracts module deferred to Phase 5, where effective terms are first entered manually with provenance before any consolidation tooling. All "never silently merge/share/overwrite" invariants remain binding.
- **Affected:** `modules/organizations_and_suppliers.md`, `personnel.md`, `documents_and_compliance.md`, `contracts.md`.

---

## D-22 — Authorization execution model (NEW; closes open item 6; refines P-06, D-16, D-20)
- **Rule:** User-initiated domain commands are implemented as **`SECURITY DEFINER` PostgreSQL functions** callable by `authenticated`, with fixed `search_path`, explicit EXECUTE grants, and **actor identity derived from the verified Supabase JWT** inside the function (never accepted as a caller argument). Each command performs authorization, the state change, the audit append and the outbox enqueue in one transaction, calling audit/outbox internals directly. A separate, narrowly privileged backend path (dedicated login role, no `service_role` shortcut) is used **only** for system actors and outbox workers, with per-category worker authorization and a restricted payload-fetch interface. Direct table writes by `authenticated` remain denied; RLS governs reads.
- **Rationale:** Removes the F0 "trusted backend supplies actor" blocker for user actions and avoids a super-privileged backend role that RLS cannot constrain.
- **Affected:** F0 migrations (grants), all module command surfaces, `modules/development.md`, `modules/users_and_security.md`.
- **Tests:** impersonated actor argument impossible by signature; command denied when JWT lacks membership/scope; cross-tenant call denied; privilege tests for every role incl. `service_role`, `PUBLIC` and worker roles.
- **Open sub-points:** API runtime for non-database concerns (uploads, email, workers) — OPEN.

## D-23 — Tenancy and ownership model (NEW; closes open item 4 in part; see `17_TENANCY_AND_OWNERSHIP_SPEC.md`)
- **Rule:** Every table is assigned exactly one **ownership class** (platform-global, client-tenant-owned, supplier-owned, relationship-scoped, or shared-registry), each with a defined owner key and RLS predicate pattern, documented in `17` **before** any F1 migration is written. A supplier is represented once as a `platform.organizations` row (capability `supplier`) linked one-to-one to its `registry.suppliers` identity.
- **Status of the content of `17`:** PROPOSED; requires owner review. This decision binds the *requirement* to specify; it does not approve unreviewed table designs.

## D-24 — Minimal approval primitive precedes document and profile approval (NEW; amends D-19 dependency order)
- **Rule:** The dependency sequence in D-19 is amended: the minimal approval primitive of A-03 is built **before** the document/profile phase that consumes it, replacing the earlier placement of all workflow work after documents.
- **Affected:** `docs/07` dependency sequence, `docs/09` roadmap.

## Items remaining OPEN (not decided by this file)
- **Data residency, target markets, legal basis and retention periods (review C5):** blocks provisioning any environment with real personal data. Owner input required.
- Status vocabularies, permission-resource matrix, API runtime, CI provider, DR objectives, MFA/SSO policy.
- Missing requirements recorded as OPEN in `10` (review C6).

## Approval record
| Entry | Direction approved | Wording reviewed by owner | Merge approval |
|---|---|---|---|
| A-01…A-05, D-22…D-24 | 2026-10-23 (in principle) | pending | pending |
