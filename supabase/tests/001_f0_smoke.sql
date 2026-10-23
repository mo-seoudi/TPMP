-- Happy path through the real grant paths (roles switched, not run as superuser).
BEGIN;
SET ROLE tpmp_event_writer;
SELECT tst.assert(audit.append_system_event('platform',NULL,'system','f0.test','foundation','test',NULL,'{"ok":true}'::jsonb,gen_random_uuid()) IS NOT NULL,'append_system_event');
SELECT tst.assert(automation.enqueue_event(NULL,'f0.test','test',gen_random_uuid(),'{"ok":true}',gen_random_uuid(),'f0-test','smoke-1') IS NOT NULL,'enqueue_event');
RESET ROLE;
SET ROLE tpmp_outbox_worker;
DO $$ DECLARE r record; ok boolean; p record; BEGIN
  SELECT * INTO r FROM automation.claim_messages('w1',1,60,8);
  PERFORM tst.assert(r.claimed_message_id IS NOT NULL,'claim returns a message');
  SELECT * INTO p FROM automation.get_message_payload(r.claimed_message_id,'w1',r.claim_token);
  PERFORM tst.assert(p.event_type='f0.test','payload readable by lease holder');
  ok := automation.complete_message(r.claimed_message_id,'w1',r.claim_token);
  PERFORM tst.assert(ok,'complete succeeds once');
  PERFORM tst.assert(NOT automation.complete_message(r.claimed_message_id,'w1',r.claim_token),'duplicate completion rejected');
END $$;
RESET ROLE;
SET ROLE tpmp_audit_verifier;
SELECT tst.assert(audit.verify_events('platform',1,9223372036854775807),'verify_events passes');
RESET ROLE;
ROLLBACK;
