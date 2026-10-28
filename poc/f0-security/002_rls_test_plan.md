# F0 RLS / identity test plan

**Status: NOT EXECUTED.** Record actual results only after running against a disposable Supabase instance using real JWT-authenticated requests.

| ID | Test | Expected |
|---|---|---|
| SEC-01 | Anonymous user reads organization A | Denied / no rows |
| SEC-02 | User A reads own active membership | Own row only |
| SEC-03 | User A reads B membership | No rows |
| SEC-04 | User A reads organization B | No rows |
| SEC-05 | User A reads note owned by organization A | Allowed |
| SEC-06 | User A reads note owned by B | No rows |
| SEC-07 | User A inserts note in A with own user ID | Allowed |
| SEC-08 | User A inserts note in B | Rejected by RLS |
| SEC-09 | User A inserts note in A with B's user ID | Rejected by RLS |
| SEC-10 | User A attempts to create own membership in B | Denied by table privileges |
| SEC-11 | User A attempts to update/revoke B membership | Denied by table privileges |
| SEC-12 | Deactivate A membership using trusted provisioner; A retries note read/write | Immediately denied |
| SEC-13 | User with membership in parent organization tries child organization | Denied unless explicit child membership |
| SEC-14 | Expired/invalid/forged JWT presented to gateway | Rejected before database operation |
| SEC-15 | User supplies actor/organization headers attempting impersonation | No effect on auth.uid() or authorization |
| SEC-16 | Inspect grants, table ownership, RLS policies and schema exposure | No unreviewed public or privileged access |

## Evidence to collect
For each test: timestamp, disposable project ID (nonsecret), authenticated role and user alias, request/SQL, HTTP/SQL outcome, actual rows affected, and PASS/FAIL. Include negative test failures in the report.

## Further mandatory gates
Multi-session concurrency, rollback atomicity, protected audit append, external checkpoints, worker lease fencing, idempotency, and service-role exposure tests are **not** covered by this small POC.
