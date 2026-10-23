# TPMP Implementation State — updated 24 October 2026 (branch `claude-v1.0`)

> Update 2026-10-24: revised F0 SQL (A-01, D-22) and an application shell now exist on branch `claude-v1.0`. Status below is exact; "verified" means a command was run and its result seen.

| Area | Architecture | Code | Validation | Deployment |
|---|---|---|---|---|
| Core Data Model 01–21 | Approved | Not a deployed schema | Design review only | None |
| F0 Database Foundation | Revised per A-01 and D-22 | `supabase/migrations/` (3 files) and `supabase/tests/` | **Verified on local PostgreSQL 16**: migrations apply on a fresh database; 4 SQL test files and the concurrency script pass (200 parallel claims, no duplicates; 200 concurrent audit appends); deliberate defects were caught. **Not verified**: Supabase itself (roles and `auth.uid()` are stood in by a test shim), worker path, external anchoring (deferred by A-01). Original archive had a runtime defect in `claim_messages` found by execution | None |
| Organizations and suppliers | Approved high-level architecture | Not started | Not started | None |
| Personnel | Approved high-level architecture | Not started | Not started | None |
| Documents/compliance | Approved high-level architecture | Not started | Not started | None |
| Workflows | Approved high-level architecture | Not started | Not started | None |
| Contracts | Approved high-level architecture | Not started | Not started | None |
| Users/security | Approved high-level architecture | Not started | Not started | None |
| Reporting | Approved high-level architecture | Not started | Not started | None |
| UI/UX design system | Principles approved | Neutral tokens only (`src/styles`); brand and layouts OPEN | Not started | None |
| Application shell (React/TS/Vite) | Structure follows proposed IA in `06` | Written: routes, module registry, provisional sign-in, placeholders, unit tests, CI workflow | **Not verified locally** (package registry unreachable from the authoring sandbox). Verification is the first GitHub Actions run | Vercel preview only if connected; no production |

## F0 known blockers
- Verify generated SQL in isolated Supabase/PostgreSQL environment.
- Trusted actor attribution and backend execution identity.
- Independent checkpoint storage/signature custody and verification.
- Worker payload access, consumer-specific permissions, idempotent external delivery.
- Segment creation/rotation/sealing, legal hold/retention operational enforcement.
- Canonical hash serialization and golden fixtures.
- Concurrency, rollback, RLS and recovery tests.
- F1 organization foreign keys and physical tenant integrity.
- Outbox poison messages: retry limit enforced only in `fail_message`; expired-lease reclaim loops forever on a crashing worker (dead-letter on reclaim needed).
- Completed outbox rows and payloads have no purge/retention path.
- `audit.append_event` serializes all writes of a stream on one segment row until commit (see A-01).
- `verify_segment` rebuilds bytes from `jsonb::text`/timestamp text; verify stored canonical bytes instead (A-01).
- No UPDATE/DELETE-blocking triggers on audit tables; immutability currently rests on privileges only (A-01).
- No segment provisioning/rotation: appends fail closed when no open segment exists.
- Tests run as a privileged role and check only `anon`/`authenticated`; role-based, `service_role`, `PUBLIC`, worker-role and concurrency tests missing.
- Actor attribution to be resolved by D-22 (JWT-derived actor in `SECURITY DEFINER` commands).

**No claim of implemented feature or production readiness should be made from an architecture document.**
