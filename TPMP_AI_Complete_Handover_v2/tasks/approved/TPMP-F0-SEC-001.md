# TPMP F0 Security POC — implementation task
**Task:** TPMP-F0-SEC-001  
**Status:** Implementation authorized for isolated development by user on 28 October 2026; merge/deployment NOT authorized.  
**Branch:** `feat/f0-security-poc`

## Objective
Prove a minimal authenticated tenant boundary before integrating the review-only F0 audit/outbox archive or the F1 React UI.

## Approved architecture
Decisions 01, 15, 16, 19–21; Supabase Auth; default-deny PostgreSQL RLS; explicit membership; platform admins have no blanket tenant access; trusted API and audit/outbox transaction.

## Files in this slice
- `poc/f0-security/README.md` — threat model, execution plan, prerequisites and gates.
- `poc/f0-security/001_membership_boundary.sql` — **disposable-only** RLS membership POC, not an approved production migration.
- `poc/f0-security/002_rls_test_plan.md` — test cases and expected outcomes.
- This task document.

## Deliberate exclusions
No production migration, no secrets, no Supabase project creation, no frontend login integration, no F0 archive execution, no broad platform-admin access, no real invitations, no audit hash-chain implementation.

## Acceptance gates
1. Confirm verified Supabase JWT identity cannot be spoofed through public API.
2. Verify membership in organization A grants only A, not B or descendants.
3. Deny anonymous, suspended, revoked and unauthorized writes.
4. Deny direct client writes to membership tables.
5. Verify restricted SQL role, function ownership, grants and RLS behavior.
6. Review audit/outbox integration and independently protected checkpoints before any production-grade migration.

## Open dependencies
Development Supabase instance, CI database harness, trusted API identity propagation, full role/resource matrix, independent checkpoint custody. **No tests claimed passed until actually executed.**

## Approval state
POC coding authorized; database deployment, merge and production release remain separate decisions.
