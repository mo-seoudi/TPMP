#!/usr/bin/env bash
# Concurrency checks against an already-migrated database ($1). Requires psql on PATH.
set -euo pipefail
DB="${1:?database name}"
P="psql -X -q -v ON_ERROR_STOP=1 -d $DB"
$P -c "TRUNCATE automation.outbox_messages CASCADE" >/dev/null 2>&1 || $P -c "DELETE FROM automation.outbox_messages"
$P -c "INSERT INTO automation.outbox_messages(event_type,aggregate_type,aggregate_id,correlation_id,producer_code,idempotency_key)
       SELECT 'c.evt','agg',gen_random_uuid(),gen_random_uuid(),'conc','k'||g FROM generate_series(1,200) g"
# 6 workers claim in parallel until empty; no message may be claimed twice.
OUT=$(mktemp)
for w in 1 2 3 4 5 6; do
  ( for i in $(seq 1 12); do $P -At -c "SELECT claimed_message_id FROM automation.claim_messages('w$w',10,60,8)"; done ) >> "$OUT" &
done
wait
TOTAL=$(grep -c . "$OUT" || true); UNIQ=$(sort -u "$OUT" | grep -c . || true)
echo "outbox: claimed=$TOTAL unique=$UNIQ"
[ "$TOTAL" = "200" ] && [ "$UNIQ" = "200" ] || { echo "FAIL: duplicate or missing claims"; exit 1; }
# 8 sessions append 25 audit events each concurrently; all must succeed with distinct sequence numbers.
for s in $(seq 1 8); do
  ( $P -c "DO \$\$ BEGIN FOR i IN 1..25 LOOP PERFORM audit.append_system_event('platform',NULL,'system','conc.test','foundation','test',NULL,'{}'::jsonb,gen_random_uuid()); END LOOP; END \$\$" ) &
done
wait
N=$($P -At -c "SELECT count(*) FROM audit.audit_events WHERE action_code='conc.test'")
D=$($P -At -c "SELECT count(DISTINCT event_seq) FROM audit.audit_events WHERE action_code='conc.test'")
V=$($P -At -c "SELECT audit.verify_events('platform',0,9223372036854775807)")
echo "audit: events=$N distinct_seq=$D verify=$V"
[ "$N" = "200" ] && [ "$D" = "200" ] && [ "$V" = "t" ] || { echo "FAIL: audit concurrency"; exit 1; }
echo "concurrency OK"
