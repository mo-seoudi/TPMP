-- Audit ledger immutability, system-path limits, and the D-22 command pattern.
BEGIN;
-- A test-only user command shaped exactly like a real D-22 command.
CREATE FUNCTION tst.demo_command(p_org uuid) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, audit, automation, tst AS $$
DECLARE eid uuid; BEGIN
  eid := audit.record_user_event('tenant:'||p_org::text, p_org, 'demo.command','demo','thing',gen_random_uuid(),'{}'::jsonb,gen_random_uuid());
  PERFORM automation.enqueue_event(p_org,'demo.command','thing',gen_random_uuid(),'{}'::jsonb,gen_random_uuid(),'demo','k-'||eid::text);
  RETURN eid; END $$;
GRANT EXECUTE ON FUNCTION tst.demo_command(uuid) TO authenticated, anon;

SET ROLE tpmp_event_writer;
SELECT tst.denied($q$INSERT INTO audit.audit_events(stream_key,actor_type,action_code,module_code,resource_type,correlation_id,occurred_at,recorded_at,schema_version,canonical_event,event_hash) VALUES('platform','system','x','m','r',gen_random_uuid(),now(),now(),1,'\x00',decode(repeat('00',32),'hex'))$q$,'direct insert into ledger');
SELECT tst.denied($q$SELECT audit.append_system_event('platform',NULL,'user','x','m','r',NULL,'{}',gen_random_uuid())$q$,'system path claiming user actor');
SELECT tst.denied($q$SELECT audit.append_system_event('platform',gen_random_uuid(),'system','x','m','r',NULL,'{}',gen_random_uuid())$q$,'platform stream with org');
SELECT tst.denied($q$SELECT audit.append_system_event('tenant:'||gen_random_uuid()::text,gen_random_uuid(),'system','x','m','r',NULL,'{}',gen_random_uuid())$q$,'tenant stream mismatch');
SELECT tst.denied($q$SELECT audit.record_event('platform',NULL,gen_random_uuid(),'user','x','m','r',NULL,'{}',gen_random_uuid(),NULL,1)$q$,'internal record_event from event_writer');
RESET ROLE;

-- D-22: actor comes from the token, never from an argument.
DO $$ DECLARE org uuid := gen_random_uuid(); uid uuid := gen_random_uuid(); eid uuid; a uuid; BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', uid::text, true);
  eid := tst.demo_command(org);
  RESET ROLE;
  SELECT actor_user_id INTO a FROM audit.audit_events WHERE id=eid;
  PERFORM tst.assert(a=uid,'audit actor equals JWT subject');
  PERFORM tst.assert((SELECT actor_type FROM audit.audit_events WHERE id=eid)='user','actor_type is user');
  PERFORM tst.assert(EXISTS(SELECT 1 FROM automation.outbox_messages WHERE aggregate_type='thing' AND organization_id=org),'outbox row written in same transaction');
END $$;
DO $$ BEGIN
  SET LOCAL ROLE anon;
  PERFORM set_config('request.jwt.claim.sub','',true);
  PERFORM tst.denied('SELECT tst.demo_command(gen_random_uuid())','command without a signed-in actor');
  RESET ROLE;
END $$;
-- authenticated cannot reach the audit or outbox internals directly, with or without a token.
DO $$ BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub',gen_random_uuid()::text,true);
  PERFORM tst.denied($q$SELECT audit.record_user_event('platform',NULL,'x','m','r',NULL,'{}',gen_random_uuid())$q$,'authenticated calling record_user_event');
  PERFORM tst.denied($q$SELECT audit.append_system_event('platform',NULL,'system','x','m','r',NULL,'{}',gen_random_uuid())$q$,'authenticated calling append_system_event');
  PERFORM tst.denied($q$SELECT automation.enqueue_event(NULL,'x','t',gen_random_uuid(),'{}',gen_random_uuid(),'p','k')$q$,'authenticated calling enqueue_event');
  PERFORM tst.denied($q$SELECT count(*) FROM audit.audit_events$q$,'authenticated reading ledger');
  RESET ROLE;
END $$;

-- Ledger is append-only even for the migration owner / superuser.
INSERT INTO audit.audit_events(stream_key,actor_type,action_code,module_code,resource_type,correlation_id,occurred_at,recorded_at,schema_version,canonical_event,event_hash)
 VALUES('platform','system','seed','m','r',gen_random_uuid(),now(),now(),1,'\x7b7d',extensions.digest('\x7b7d'::bytea,'sha256'));
SELECT tst.denied($q$UPDATE audit.audit_events SET action_code='tampered'$q$,'update ledger');
SELECT tst.denied($q$DELETE FROM audit.audit_events$q$,'delete ledger');
SELECT tst.denied($q$TRUNCATE audit.audit_events$q$,'truncate ledger');
SELECT tst.denied($q$INSERT INTO audit.audit_events(stream_key,actor_type,action_code,module_code,resource_type,correlation_id,occurred_at,recorded_at,schema_version,canonical_event,event_hash) VALUES('bad stream','system','x','m','r',gen_random_uuid(),now(),now(),1,'\x00',decode(repeat('00',32),'hex'))$q$,'invalid stream key');
SELECT tst.denied($q$INSERT INTO audit.audit_events(stream_key,actor_type,action_code,module_code,resource_type,correlation_id,occurred_at,recorded_at,schema_version,canonical_event,event_hash) VALUES('platform','user','x','m','r',gen_random_uuid(),now(),now(),1,'\x00',decode(repeat('00',32),'hex'))$q$,'user actor without id');

-- Tamper detection: a privileged actor who disables the trigger is caught by verification of stored bytes.
SELECT tst.assert(audit.verify_events('platform',0,9223372036854775807),'clean ledger verifies');
ALTER TABLE audit.audit_events DISABLE TRIGGER trg_audit_events_no_update_delete;
UPDATE audit.audit_events SET canonical_event='\x7b2278227d' WHERE action_code='seed';
SELECT tst.assert(NOT audit.verify_events('platform',0,9223372036854775807),'tampered bytes detected');
ROLLBACK;
