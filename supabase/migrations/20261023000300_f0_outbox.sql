-- F0.003 (revised): transactional outbox with leases and fencing.
-- Fixes vs the F0 v1 review archive (found by executing it):
--  * claim_messages failed at runtime ("message_id is ambiguous"); OUT columns renamed.
--  * a message whose worker always crashed was reclaimed forever; reclaim now dead-letters
--    once the attempt limit is reached.
--  * completed rows were never purged; purge_completed added.
--  * workers had no restricted payload path; get_message_payload added (lease-checked).
-- At-least-once delivery only. Consumers must be idempotent (receipt or external key).

CREATE TABLE automation.outbox_messages (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 organization_id uuid,
 event_type text NOT NULL CHECK(length(event_type)>0),
 aggregate_type text NOT NULL,
 aggregate_id uuid NOT NULL,
 payload jsonb NOT NULL DEFAULT '{}'::jsonb CHECK(pg_column_size(payload) <= 65536),
 schema_version integer NOT NULL DEFAULT 1 CHECK(schema_version>0),
 correlation_id uuid NOT NULL,
 producer_code text NOT NULL,
 idempotency_key text NOT NULL,
 processing_status text NOT NULL DEFAULT 'pending'
   CHECK(processing_status IN ('pending','leased','completed','dead_letter')),
 attempt_count integer NOT NULL DEFAULT 0 CHECK(attempt_count>=0),
 available_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 lease_owner text,
 lease_token uuid,
 locked_until timestamptz,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 processed_at timestamptz,
 UNIQUE(producer_code,idempotency_key),
 CONSTRAINT ck_outbox_lease CHECK (
  (processing_status='leased' AND lease_owner IS NOT NULL AND lease_token IS NOT NULL AND locked_until IS NOT NULL)
  OR (processing_status<>'leased' AND lease_owner IS NULL AND lease_token IS NULL AND locked_until IS NULL))
);
CREATE INDEX idx_outbox_claim ON automation.outbox_messages(available_at,id) WHERE processing_status IN ('pending','leased');
CREATE INDEX idx_outbox_org_created ON automation.outbox_messages(organization_id,created_at DESC);
CREATE INDEX idx_outbox_aggregate ON automation.outbox_messages(aggregate_type,aggregate_id,created_at DESC);
CREATE INDEX idx_outbox_completed ON automation.outbox_messages(processed_at) WHERE processing_status='completed';

CREATE TABLE automation.outbox_delivery_attempts (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 message_id uuid NOT NULL REFERENCES automation.outbox_messages(id) ON DELETE CASCADE,
 attempt_number integer NOT NULL CHECK(attempt_number>0),
 worker_code text NOT NULL,
 attempted_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 outcome text NOT NULL CHECK(outcome IN ('claimed','completed','retry','dead_letter')),
 error_code text,
 UNIQUE(message_id,attempt_number,outcome)
);
CREATE TABLE automation.consumer_receipts (
 consumer_code text NOT NULL,
 message_id uuid NOT NULL REFERENCES automation.outbox_messages(id) ON DELETE CASCADE,
 processed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 result_reference text,
 PRIMARY KEY(consumer_code,message_id)
);
CREATE TABLE automation.outbox_dead_letters (
 message_id uuid PRIMARY KEY REFERENCES automation.outbox_messages(id),
 reason_code text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 resolved_at timestamptz,
 resolved_by text
);
REVOKE ALL ON ALL TABLES IN SCHEMA automation FROM PUBLIC, anon, authenticated, service_role;

-- Producer path. Granted to the narrow backend role; D-22 commands call it from their own
-- SECURITY DEFINER bodies in the same transaction as the state change.
CREATE FUNCTION automation.enqueue_event(
 p_organization_id uuid, p_event_type text, p_aggregate_type text, p_aggregate_id uuid,
 p_payload jsonb, p_correlation_id uuid, p_producer_code text, p_idempotency_key text,
 p_schema_version integer DEFAULT 1
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, automation AS $$
DECLARE mid uuid;
BEGIN
 IF p_event_type IS NULL OR p_aggregate_type IS NULL OR p_aggregate_id IS NULL OR p_correlation_id IS NULL
    OR p_producer_code IS NULL OR p_idempotency_key IS NULL THEN RAISE EXCEPTION 'Invalid event'; END IF;
 INSERT INTO automation.outbox_messages(organization_id,event_type,aggregate_type,aggregate_id,payload,
   correlation_id,producer_code,idempotency_key,schema_version)
 VALUES(p_organization_id,p_event_type,p_aggregate_type,p_aggregate_id,coalesce(p_payload,'{}'::jsonb),
   p_correlation_id,p_producer_code,p_idempotency_key,p_schema_version)
 ON CONFLICT(producer_code,idempotency_key) DO NOTHING RETURNING id INTO mid;
 IF mid IS NULL THEN
  SELECT id INTO mid FROM automation.outbox_messages WHERE producer_code=p_producer_code AND idempotency_key=p_idempotency_key;
  IF NOT EXISTS(SELECT 1 FROM automation.outbox_messages WHERE id=mid AND
     organization_id IS NOT DISTINCT FROM p_organization_id AND event_type=p_event_type AND
     aggregate_type=p_aggregate_type AND aggregate_id=p_aggregate_id AND
     payload=coalesce(p_payload,'{}'::jsonb) AND correlation_id=p_correlation_id AND schema_version=p_schema_version)
  THEN RAISE EXCEPTION 'Idempotency key collision'; END IF;
 END IF;
 RETURN mid;
END $$;
REVOKE ALL ON FUNCTION automation.enqueue_event(uuid,text,text,uuid,jsonb,uuid,text,text,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION automation.enqueue_event(uuid,text,text,uuid,jsonb,uuid,text,text,integer) TO tpmp_event_writer;

-- Claim: first dead-letters expired leases that already reached the attempt limit (poison
-- messages), then leases eligible rows with SKIP LOCKED. Returns ids and fencing tokens only.
CREATE FUNCTION automation.claim_messages(p_worker text, p_batch integer DEFAULT 20,
 p_lease_seconds integer DEFAULT 120, p_max_attempts integer DEFAULT 8)
RETURNS TABLE(claimed_message_id uuid, claim_token uuid)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, automation AS $$
BEGIN
 IF p_worker IS NULL OR length(p_worker)=0 OR p_batch NOT BETWEEN 1 AND 100
    OR p_lease_seconds NOT BETWEEN 15 AND 3600 OR p_max_attempts<1 THEN
   RAISE EXCEPTION 'Invalid lease parameters'; END IF;

 WITH poisoned AS (
   UPDATE automation.outbox_messages m
      SET processing_status='dead_letter', lease_owner=NULL, lease_token=NULL, locked_until=NULL
    WHERE m.id IN (SELECT x.id FROM automation.outbox_messages x
                    WHERE x.processing_status='leased' AND x.locked_until<clock_timestamp()
                      AND x.attempt_count>=p_max_attempts
                    FOR UPDATE SKIP LOCKED)
   RETURNING m.id, m.attempt_count
 ), logged AS (
   INSERT INTO automation.outbox_delivery_attempts(message_id,attempt_number,worker_code,outcome,error_code)
   SELECT id, attempt_count, p_worker, 'dead_letter', 'lease_expired_max_attempts' FROM poisoned
   ON CONFLICT DO NOTHING RETURNING message_id
 )
 INSERT INTO automation.outbox_dead_letters(message_id,reason_code)
 SELECT id,'lease_expired_max_attempts' FROM poisoned ON CONFLICT(message_id) DO NOTHING;

 RETURN QUERY
 WITH candidates AS (
   SELECT m.id FROM automation.outbox_messages m
    WHERE (m.processing_status='pending' AND m.available_at<=clock_timestamp())
       OR (m.processing_status='leased' AND m.locked_until<clock_timestamp() AND m.attempt_count<p_max_attempts)
    ORDER BY m.available_at, m.id LIMIT p_batch FOR UPDATE SKIP LOCKED
 ), claimed AS (
   UPDATE automation.outbox_messages m
      SET processing_status='leased', lease_owner=p_worker, lease_token=gen_random_uuid(),
          locked_until=clock_timestamp()+make_interval(secs=>p_lease_seconds), attempt_count=m.attempt_count+1
     FROM candidates c WHERE m.id=c.id
   RETURNING m.id AS mid, m.lease_token AS tok, m.attempt_count AS ac
 ), attempts AS (
   INSERT INTO automation.outbox_delivery_attempts(message_id,attempt_number,worker_code,outcome)
   SELECT mid, ac, p_worker, 'claimed' FROM claimed RETURNING message_id AS aid
 )
 SELECT claimed.mid, claimed.tok FROM claimed JOIN attempts ON attempts.aid=claimed.mid;
END $$;
REVOKE ALL ON FUNCTION automation.claim_messages(text,integer,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION automation.claim_messages(text,integer,integer,integer) TO tpmp_outbox_worker;

-- Restricted payload read: only the current valid lease holder. Per-category worker
-- authorization is OPEN (see docs/10) and must be added before any real consumer ships.
CREATE FUNCTION automation.get_message_payload(p_id uuid, p_worker text, p_token uuid)
RETURNS TABLE(event_type text, aggregate_type text, aggregate_id uuid, organization_id uuid,
              payload jsonb, schema_version integer, correlation_id uuid)
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, automation AS $$
 SELECT m.event_type,m.aggregate_type,m.aggregate_id,m.organization_id,m.payload,m.schema_version,m.correlation_id
   FROM automation.outbox_messages m
  WHERE m.id=p_id AND m.processing_status='leased' AND m.lease_owner=p_worker
    AND m.lease_token=p_token AND m.locked_until>clock_timestamp();
$$;
REVOKE ALL ON FUNCTION automation.get_message_payload(uuid,text,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION automation.get_message_payload(uuid,text,uuid) TO tpmp_outbox_worker;

CREATE FUNCTION automation.complete_message(p_id uuid, p_worker text, p_token uuid)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, automation AS $$
DECLARE attempts integer;
BEGIN
 UPDATE automation.outbox_messages SET processing_status='completed', processed_at=clock_timestamp(),
   lease_owner=NULL, lease_token=NULL, locked_until=NULL
 WHERE id=p_id AND processing_status='leased' AND lease_owner=p_worker AND lease_token=p_token AND locked_until>clock_timestamp()
 RETURNING attempt_count INTO attempts;
 IF NOT FOUND THEN RETURN false; END IF;
 INSERT INTO automation.outbox_delivery_attempts(message_id,attempt_number,worker_code,outcome)
 VALUES(p_id,attempts,p_worker,'completed');
 RETURN true;
END $$;
REVOKE ALL ON FUNCTION automation.complete_message(uuid,text,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION automation.complete_message(uuid,text,uuid) TO tpmp_outbox_worker;

CREATE FUNCTION automation.fail_message(p_id uuid, p_worker text, p_token uuid, p_error_code text,
 p_max_attempts integer DEFAULT 8)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, automation AS $$
DECLARE n integer; outcome text;
BEGIN
 IF p_max_attempts<1 THEN RAISE EXCEPTION 'Invalid retry limit'; END IF;
 SELECT attempt_count INTO n FROM automation.outbox_messages
  WHERE id=p_id AND processing_status='leased' AND lease_owner=p_worker AND lease_token=p_token
    AND locked_until>clock_timestamp() FOR UPDATE;
 IF NOT FOUND THEN RETURN false; END IF;
 outcome := CASE WHEN n>=p_max_attempts THEN 'dead_letter' ELSE 'retry' END;
 UPDATE automation.outbox_messages
    SET processing_status=CASE WHEN n>=p_max_attempts THEN 'dead_letter' ELSE 'pending' END,
        available_at=clock_timestamp()+make_interval(secs=>least(3600,30*power(2,least(n,7))::integer)),
        lease_owner=NULL, lease_token=NULL, locked_until=NULL
  WHERE id=p_id;
 INSERT INTO automation.outbox_delivery_attempts(message_id,attempt_number,worker_code,outcome,error_code)
 VALUES(p_id,n,p_worker,outcome,left(p_error_code,120));
 IF outcome='dead_letter' THEN
   INSERT INTO automation.outbox_dead_letters(message_id,reason_code)
   VALUES(p_id,left(coalesce(p_error_code,'unknown'),120)) ON CONFLICT(message_id) DO NOTHING;
 END IF;
 RETURN true;
END $$;
REVOKE ALL ON FUNCTION automation.fail_message(uuid,text,uuid,text,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION automation.fail_message(uuid,text,uuid,text,integer) TO tpmp_outbox_worker;

-- Retention for completed rows (and, by cascade, their attempts and receipts). Dead-lettered
-- rows are never purged here. The age is a caller decision; no default is invented (OPEN).
CREATE FUNCTION automation.purge_completed(p_older_than interval, p_limit integer DEFAULT 1000)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, automation AS $$
DECLARE n integer;
BEGIN
 IF p_older_than IS NULL OR p_older_than < interval '1 hour' OR p_limit NOT BETWEEN 1 AND 10000 THEN
   RAISE EXCEPTION 'Invalid purge parameters'; END IF;
 WITH doomed AS (SELECT id FROM automation.outbox_messages
                  WHERE processing_status='completed' AND processed_at < clock_timestamp()-p_older_than
                  ORDER BY processed_at LIMIT p_limit FOR UPDATE SKIP LOCKED)
 DELETE FROM automation.outbox_messages m USING doomed d WHERE m.id=d.id;
 GET DIAGNOSTICS n = ROW_COUNT;
 RETURN n;
END $$;
REVOKE ALL ON FUNCTION automation.purge_completed(interval,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION automation.purge_completed(interval,integer) TO tpmp_outbox_worker;
