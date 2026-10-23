#!/usr/bin/env bash
# Builds a fresh disposable database, applies the Supabase shim, all migrations and all SQL tests.
# Usage: scripts/db-test.sh [dbname]   (needs a reachable PostgreSQL 15+ and a superuser connection)
set -euo pipefail
cd "$(dirname "$0")/.."
DB="${1:-tpmp_f0_test}"
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS $DB" -c "CREATE DATABASE $DB"
P="psql -X -q -v ON_ERROR_STOP=1 -d $DB"
$P -f supabase/tests/support/00_supabase_shim.sql
for f in supabase/migrations/*.sql; do echo "migrate  $f"; $P -f "$f"; done
for f in supabase/tests/0*.sql; do echo "test     $f"; $P -o /dev/null -f "$f"; done
scripts/db-concurrency.sh "$DB"
echo "ALL DATABASE TESTS PASSED"
