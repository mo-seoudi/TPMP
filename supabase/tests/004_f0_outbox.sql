BEGIN;
DO $$ DECLARE m1 uuid; m2 uuid; r record; t1 uuid; agg uuid := gen_random_uuid(); corr uuid := gen_random_uuid(); n int; st text; BEGIN
  -- idempotent enqueue
  m1 := automation.enqueue_event(NULL,'t.evt','agg',agg,'{"a":1}',corr,'prod','key-1');
  m2 := automation.enqueue_event(NULL,'t.evt','agg',agg,'{"a":1}',corr,'prod','key-1');
  PERFORM tst.assert(m1=m2,'same idempotency key and content returns same message');
  PERFORM tst.denied(format('SELECT automation.enqueue_event(NULL,%L,%L,%L,%L,%L,%L,%L)','t.evt','agg',agg,'{"a":2}',corr,'prod','key-1'),'idempotency key reused with different payload');

  -- stale token cannot complete after reclaim
  SELECT * INTO r FROM automation.claim_messages('w1',1,60,8); t1 := r.claim_token;
  PERFORM tst.assert(r.claimed_message_id=m1,'claimed');
  UPDATE automation.outbox_messages SET locked_until=clock_timestamp()-interval '1 second' WHERE id=m1;
  SELECT * INTO r FROM automation.claim_messages('w2',1,60,8);
  PERFORM tst.assert(r.claimed_message_id=m1 AND r.claim_token<>t1,'expired lease reclaimed with a new token');
  PERFORM tst.assert(NOT automation.complete_message(m1,'w1',t1),'stale worker token rejected');
  PERFORM tst.assert(NOT EXISTS(SELECT 1 FROM automation.get_message_payload(m1,'w1',t1)),'stale token cannot read payload');
  PERFORM tst.assert(automation.complete_message(m1,'w2',r.claim_token),'current holder completes');

  -- retry then dead-letter via fail_message
  m2 := automation.enqueue_event(NULL,'t.evt2','agg',gen_random_uuid(),'{}',gen_random_uuid(),'prod','key-2');
  SELECT * INTO r FROM automation.claim_messages('w1',1,60,2);
  PERFORM tst.assert(automation.fail_message(m2,'w1',r.claim_token,'boom',2),'first failure recorded');
  SELECT processing_status INTO st FROM automation.outbox_messages WHERE id=m2; PERFORM tst.assert(st='pending','retry scheduled');
  UPDATE automation.outbox_messages SET available_at=clock_timestamp() WHERE id=m2;
  SELECT * INTO r FROM automation.claim_messages('w1',1,60,2);
  PERFORM tst.assert(automation.fail_message(m2,'w1',r.claim_token,'boom',2),'second failure recorded');
  SELECT processing_status INTO st FROM automation.outbox_messages WHERE id=m2; PERFORM tst.assert(st='dead_letter','dead-lettered at attempt limit');
  PERFORM tst.assert(EXISTS(SELECT 1 FROM automation.outbox_dead_letters WHERE message_id=m2),'dead letter row exists');

  -- poison message: worker crashes every time (never calls fail_message); reclaim must dead-letter it
  m2 := automation.enqueue_event(NULL,'t.poison','agg',gen_random_uuid(),'{}',gen_random_uuid(),'prod','key-3');
  FOR n IN 1..3 LOOP
    PERFORM 1 FROM automation.claim_messages('crashy',1,60,3);
    UPDATE automation.outbox_messages SET locked_until=clock_timestamp()-interval '1 second' WHERE id=m2 AND processing_status='leased';
  END LOOP;
  PERFORM 1 FROM automation.claim_messages('crashy',1,60,3);
  SELECT processing_status INTO st FROM automation.outbox_messages WHERE id=m2;
  PERFORM tst.assert(st='dead_letter','poison message dead-lettered instead of looping forever');

  -- purge
  PERFORM tst.assert(automation.purge_completed(interval '1 hour')=0,'recent completed rows are kept');
  UPDATE automation.outbox_messages SET processed_at=clock_timestamp()-interval '2 days' WHERE id=m1;
  PERFORM tst.assert(automation.purge_completed(interval '1 day')=1,'old completed row purged');
  PERFORM tst.assert(NOT EXISTS(SELECT 1 FROM automation.outbox_messages WHERE id=m1),'purged row gone');
  PERFORM tst.assert(EXISTS(SELECT 1 FROM automation.outbox_dead_letters),'dead letters are retained by purge');
  PERFORM tst.denied('SELECT automation.purge_completed(interval ''1 minute'')','purge age floor enforced');
END $$;
ROLLBACK;
