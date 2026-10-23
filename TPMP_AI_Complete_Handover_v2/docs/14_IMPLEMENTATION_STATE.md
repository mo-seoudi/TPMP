# TPMP Implementation State — 23 October 2026

| Area | Architecture | Code | Validation | Deployment |
|---|---|---|---|---|
| Core Data Model 01–21 | Approved | Not a deployed schema | Design review only | None |
| F0 Database Foundation | Physical design specified | Review-only SQL archive generated | PostgreSQL/Supabase execution not confirmed | None |
| Organizations and suppliers | Approved high-level architecture | Not started | Not started | None |
| Personnel | Approved high-level architecture | Not started | Not started | None |
| Documents/compliance | Approved high-level architecture | Not started | Not started | None |
| Workflows | Approved high-level architecture | Not started | Not started | None |
| Contracts | Approved high-level architecture | Not started | Not started | None |
| Users/security | Approved high-level architecture | Not started | Not started | None |
| Reporting | Approved high-level architecture | Not started | Not started | None |
| UI/UX design system | Principles approved | Not started | Not started | None |

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
