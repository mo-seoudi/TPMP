# PostgreSQL Architecture and Delivery Strategy

## Stack and deployment
React + TypeScript; Supabase Postgres/Auth/Storage; Vercel; GitHub. Modular monolith with typed APIs and explicit module contracts. Isolated development, staging and production Supabase/Vercel environments. No deployment without approval and tests.

## Logical schemas
`platform`, `registry`, `tenant`, `security`, `identity`, `compliance`, `documents`, `contracts`, `workflow`, `integration`, `automation`, `reporting`, `audit`.

## Physical modeling
UUID stable identities; typed core relational fields; validated versioned JSONB for custom data; module-owned immutable version tables; recorded versus effective time; separate proposal/approval/effectiveness; current pointers as transactional projections; optimistic concurrency via row revision. Effective intervals use half-open `[from,to)` ranges where appropriate. Historical queries distinguish what was effective from what was known at the time.

## Cross-tenant integrity
Shared supplier registry remains global. Tenant-owned relationships, engagements, assignments and compliance records require composite FK or equivalent validated integrity so references cannot cross client/supplier boundaries. Default deny RLS and server-side authorization. Exact FK strategy for every table is a later physical schema deliverable.

## Migration strategy — approved Decision 19
One ordered Supabase migration history per environment; module-tagged migration manifest, dependencies and ownership; expand/transition/contract for breaking changes; additive first, backfill, consumer transition, validation, then constraint/removal. Review SQL, RLS, privileges, concurrency, lifecycle and backward compatibility before release. Never edit an already applied migration in place; create a new migration.

## Dependency sequence
> **Amended by D-24 (2026-10-23, wording pending owner review):** the minimal approval primitive (A-03) is built before the document/profile phase. The sequence below is the original and is otherwise unchanged; see `09` for the current phase order.

F0 database schemas/privileges/audit/outbox primitives -> F1 organizations/hierarchy/memberships -> security/identity -> supplier registry/relationships/engagements -> documents/compliance foundations -> workflow definitions -> operational profile/personnel/evidence/contract lifecycles -> automation/integration -> reporting. Actual modules may be developed in smaller dependency-ordered slices.

## Database conventions
`id uuid`; `created_at/recorded_at timestamptz`; `created_by`; `version_number`; `effective_from/effective_to`; `supersedes_version_id`; `row_revision bigint`. Constraint prefixes `uq_`, `fk_`, `ck_`, indexes `idx_`, policies `rls_`. PostgreSQL identifiers must respect 63-byte limit. Status concepts remain module-specific; prefer lookup/check structures over frequently altered enums.

## Release gates
SQL parse/apply; PK/FK/check; RLS/tenant isolation; API contract compatibility; version/temporal integrity; optimistic concurrency; indexing/performance; clean reset; staging smoke and rollback/recovery plan; explicit release approval. Tests in CI. Migrations and Vercel app release must tolerate overlapping application versions.

## Reporting strategy
Hybrid live operational queries plus controlled projections and snapshots. Versioned metric definitions, tenant-specific thresholds, watermark/idempotent runs, reconciliation and freshness labels. Current authorization governs historical access; no aggregate leakage. Sample metrics: active supplier relationships, satisfied requirements, documents expiring in 30 days, pending workflow tasks.
