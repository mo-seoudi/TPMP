# F0 Foundation — Specification and Implementation Handoff

## Decision baseline
Decisions 20–21: central append-only audit ledger with module-owned immutable histories; segmented cryptographic hash chains, independently protected checkpoints, retention/legal holds and controlled redaction/erasure. Decision 19: dependency-ordered migrations and staged rollout.

## F0 architecture table inventory
`audit.audit_segments`, `audit_events`, `integrity_checkpoints`, `integrity_verification_runs`, `retention_policies`, `legal_holds`, `retention_execution_events`; `automation.outbox_messages`, `outbox_delivery_attempts`, `consumer_receipts`, `outbox_dead_letters`. These are **target specification** tables, not a claim every table is fully implemented in the initial archive.

## Audit design
Audit segment holds scope, period, state, hash algorithm/version and chain head. Trusted append locks segment, assigns a serialized sequence, computes canonical event hash and inserts atomically. Sealed segments are immutable. Checkpoint metadata must correspond to independently retained protected checkpoint material. Hash canonicalization needs versioned golden fixtures; no reliance on accidental JSONB/timestamp formatting.

## Outbox design
Business state, audit and outbox event commit in one transaction. Workers claim messages with leases and fencing; at-least-once delivery; attempts, idempotent consumer receipts, retry/backoff and dead-letter. Restrict worker payload access and categories.

## Existing generated review archive
`TPMP_F0_Implementation_v1.0.zip` was generated in the project conversation on 23 October 2026. It contains three ordered SQL migrations (`f0_schemas_privileges`, `f0_audit`, `f0_outbox`), two SQL tests, README and migration manifest. **It has not been executed against PostgreSQL/Supabase.** It is a first reviewable implementation, not production-ready.

## Known blockers explicitly stated in its README
- Trusted actor attribution not yet integrated with verified backend identity.
- Independent immutable checkpoint store, publisher, signing/key custody and external verifier not implemented.
- Audit segment provisioning/rotation, legal-hold enforcement and retention execution not operational.
- Hash canonical serialization uses `jsonb::text` and timestamp text and needs pinned canonical fixtures/version handling.
- Worker payload retrieval, per-category authorization and consumer receipt/effect integration incomplete.
- Concurrent two-session, rollback, replay/idempotency and RLS/privilege integration tests not yet run.
- Organization FKs to be introduced after F1; no staging/production deployment.

## Required next step
Review archive SQL line by line, reconcile against target table inventory, run clean disposable Supabase/PostgreSQL tests, fix security blockers, establish external checkpoint design and test harness. Do not promote to staging before review gates are passed.
