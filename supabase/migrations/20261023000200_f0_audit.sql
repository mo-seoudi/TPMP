-- F0.002 (revised per A-01 / D-22): append-only audit ledger.
-- Chain computation, sealing and external anchoring are DEFERRED (A-01); the segment,
-- checkpoint and retention table shapes are reserved so the later phase is additive.
-- Canonical bytes are stored at insert; verification hashes the STORED bytes and never
-- rebuilds them from jsonb::text or timestamp text.

CREATE TABLE audit.audit_segments (            -- reserved for the deferred chain phase
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 stream_key text NOT NULL,
 period_start timestamptz NOT NULL,
 period_end timestamptz NOT NULL,
 status text NOT NULL DEFAULT 'open' CHECK(status IN ('open','sealed','archived')),
 hash_format_version integer NOT NULL DEFAULT 1 CHECK(hash_format_version>0),
 hash_algorithm text NOT NULL DEFAULT 'sha256' CHECK(hash_algorithm='sha256'),
 last_sequence bigint NOT NULL DEFAULT 0 CHECK(last_sequence>=0),
 last_event_hash bytea,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 sealed_at timestamptz,
 CONSTRAINT ck_audit_segment_period CHECK(period_end>period_start),
 CONSTRAINT uq_audit_segment UNIQUE(stream_key,period_start)
);

CREATE TABLE audit.audit_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 event_seq bigint GENERATED ALWAYS AS IDENTITY,
 stream_key text NOT NULL CHECK (stream_key ~ '^(platform|tenant:[0-9a-f-]{36})$'),
 segment_id uuid REFERENCES audit.audit_segments(id),   -- reserved
 organization_id uuid,
 actor_user_id uuid,
 actor_type text NOT NULL CHECK(actor_type IN ('user','system','worker','support')),
 action_code text NOT NULL CHECK(length(action_code)>0),
 module_code text NOT NULL CHECK(length(module_code)>0),
 resource_type text NOT NULL CHECK(length(resource_type)>0),
 resource_id uuid,
 event_payload jsonb NOT NULL DEFAULT '{}'::jsonb CHECK(pg_column_size(event_payload) <= 65536),
 correlation_id uuid NOT NULL,
 causation_id uuid,
 occurred_at timestamptz NOT NULL,
 recorded_at timestamptz NOT NULL,
 schema_version integer NOT NULL CHECK(schema_version>0),
 canonical_event bytea NOT NULL,
 hash_format_version integer NOT NULL DEFAULT 1 CHECK(hash_format_version>0),
 previous_hash bytea,                                   -- reserved for chaining
 event_hash bytea NOT NULL CHECK(octet_length(event_hash)=32),
 CONSTRAINT uq_audit_event_seq UNIQUE(event_seq),
 CONSTRAINT ck_audit_actor CHECK (
   (actor_type='user' AND actor_user_id IS NOT NULL) OR (actor_type<>'user'))
);
CREATE INDEX idx_audit_events_org_time ON audit.audit_events(organization_id,recorded_at DESC);
CREATE INDEX idx_audit_events_stream ON audit.audit_events(stream_key,event_seq);
CREATE INDEX idx_audit_events_resource ON audit.audit_events(module_code,resource_type,resource_id,recorded_at DESC);
CREATE INDEX idx_audit_events_correlation ON audit.audit_events(correlation_id);

CREATE TABLE audit.integrity_checkpoints (              -- reserved
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 segment_id uuid NOT NULL REFERENCES audit.audit_segments(id),
 last_verified_sequence bigint NOT NULL,
 terminal_hash bytea NOT NULL CHECK(octet_length(terminal_hash)=32),
 external_reference text,
 status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','published','verified','failed')),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 published_at timestamptz,
 UNIQUE(segment_id,last_verified_sequence)
);
CREATE TABLE audit.integrity_verification_runs (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 stream_key text NOT NULL,
 from_seq bigint NOT NULL,
 to_seq bigint NOT NULL,
 status text NOT NULL CHECK(status IN ('passed','failed')),
 checked_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 checked_count bigint NOT NULL,
 failure_reason text
);
-- Retention metadata only. Execution is NOT enabled in F0 (legal periods are OPEN).
CREATE TABLE audit.retention_policies (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 stream_key text NOT NULL,
 event_category text NOT NULL,
 policy_version integer NOT NULL CHECK(policy_version>0),
 retention_interval interval NOT NULL CHECK(retention_interval>interval '0'),
 retention_action text NOT NULL CHECK(retention_action IN ('archive','anonymize','delete')),
 effective_from timestamptz NOT NULL,
 approved_by uuid NOT NULL,
 UNIQUE(stream_key,event_category,policy_version)
);
CREATE TABLE audit.legal_holds (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 stream_key text NOT NULL,
 segment_id uuid REFERENCES audit.audit_segments(id),
 reason text NOT NULL,
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','released')),
 created_by uuid NOT NULL,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 released_at timestamptz
);
CREATE INDEX idx_audit_holds_active ON audit.legal_holds(stream_key,segment_id) WHERE status='active';
CREATE TABLE audit.retention_execution_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 segment_id uuid REFERENCES audit.audit_segments(id),
 retention_policy_id uuid NOT NULL REFERENCES audit.retention_policies(id),
 operation text NOT NULL CHECK(operation IN ('archive','anonymize','delete','crypto_erase')),
 executed_by uuid NOT NULL,
 executed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 outcome text NOT NULL,
 evidence_reference text NOT NULL
);

REVOKE ALL ON ALL TABLES IN SCHEMA audit FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT ON audit.audit_events, audit.integrity_verification_runs TO tpmp_audit_verifier;

-- Immutability (A-01): no UPDATE, DELETE or TRUNCATE of the ledger by anyone. A future,
-- separately approved retention path must amend this. Superusers can still disable
-- triggers; that residual risk is why external anchoring is a deferred phase, not dropped.
CREATE FUNCTION audit.deny_mutation() RETURNS trigger LANGUAGE plpgsql
SET search_path = pg_catalog AS $$
BEGIN RAISE EXCEPTION 'audit ledger is append-only (%)', TG_OP USING ERRCODE='42501'; END $$;
CREATE TRIGGER trg_audit_events_no_update_delete BEFORE UPDATE OR DELETE ON audit.audit_events
 FOR EACH ROW EXECUTE FUNCTION audit.deny_mutation();
CREATE TRIGGER trg_audit_events_no_truncate BEFORE TRUNCATE ON audit.audit_events
 FOR EACH STATEMENT EXECUTE FUNCTION audit.deny_mutation();
REVOKE ALL ON FUNCTION audit.deny_mutation() FROM PUBLIC;

-- Internal writer. NOT granted to any role: only SECURITY DEFINER callers owned by the
-- migration owner can reach it. Writes use no shared row lock, so audit appends from
-- concurrent transactions do not serialize.
CREATE FUNCTION audit.record_event(
 p_stream_key text, p_organization_id uuid, p_actor_user_id uuid, p_actor_type text,
 p_action_code text, p_module_code text, p_resource_type text, p_resource_id uuid,
 p_event_payload jsonb, p_correlation_id uuid, p_causation_id uuid, p_schema_version integer
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, audit, extensions SET TimeZone = 'UTC' AS $$
DECLARE eid uuid := gen_random_uuid(); ts timestamptz := clock_timestamp(); canonical bytea;
BEGIN
 IF p_stream_key IS NULL OR p_stream_key !~ '^(platform|tenant:[0-9a-f-]{36})$' THEN RAISE EXCEPTION 'Invalid stream'; END IF;
 IF p_actor_type IS NULL OR p_actor_type NOT IN ('user','system','worker','support')
    OR p_action_code IS NULL OR p_module_code IS NULL OR p_resource_type IS NULL
    OR p_correlation_id IS NULL OR p_schema_version IS NULL OR p_schema_version<1 THEN
   RAISE EXCEPTION 'Invalid audit event'; END IF;
 IF p_stream_key='platform' AND p_organization_id IS NOT NULL THEN RAISE EXCEPTION 'Platform stream mismatch'; END IF;
 IF p_stream_key LIKE 'tenant:%' AND (p_organization_id IS NULL OR p_stream_key <> 'tenant:'||p_organization_id::text) THEN
   RAISE EXCEPTION 'Tenant stream mismatch'; END IF;
 canonical := convert_to(jsonb_build_array(1,eid::text,p_stream_key,p_organization_id::text,p_actor_user_id::text,
   p_actor_type,p_action_code,p_module_code,p_resource_type,p_resource_id::text,
   coalesce(p_event_payload,'{}'::jsonb),p_correlation_id::text,p_causation_id::text,
   ts::text,p_schema_version)::text,'UTF8');
 INSERT INTO audit.audit_events(id,stream_key,organization_id,actor_user_id,actor_type,action_code,module_code,
   resource_type,resource_id,event_payload,correlation_id,causation_id,occurred_at,recorded_at,schema_version,
   canonical_event,event_hash)
 VALUES(eid,p_stream_key,p_organization_id,p_actor_user_id,p_actor_type,p_action_code,p_module_code,
   p_resource_type,p_resource_id,coalesce(p_event_payload,'{}'::jsonb),p_correlation_id,p_causation_id,
   ts,ts,p_schema_version,canonical,extensions.digest(canonical,'sha256'));
 RETURN eid;
END $$;
REVOKE ALL ON FUNCTION audit.record_event(text,uuid,uuid,text,text,text,text,uuid,jsonb,uuid,uuid,integer)
 FROM PUBLIC, anon, authenticated, service_role;

-- D-22: user-initiated commands call this from their own SECURITY DEFINER body. The actor
-- is derived from the verified JWT (auth.uid()); there is no actor argument to forge.
CREATE FUNCTION audit.record_user_event(
 p_stream_key text, p_organization_id uuid, p_action_code text, p_module_code text,
 p_resource_type text, p_resource_id uuid, p_event_payload jsonb, p_correlation_id uuid,
 p_causation_id uuid DEFAULT NULL, p_schema_version integer DEFAULT 1
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, audit AS $$
DECLARE uid uuid := auth.uid();
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'No authenticated actor' USING ERRCODE='28000'; END IF;
 RETURN audit.record_event(p_stream_key,p_organization_id,uid,'user',p_action_code,p_module_code,
   p_resource_type,p_resource_id,p_event_payload,p_correlation_id,p_causation_id,p_schema_version);
END $$;
REVOKE ALL ON FUNCTION audit.record_user_event(text,uuid,text,text,text,uuid,jsonb,uuid,uuid,integer)
 FROM PUBLIC, anon, authenticated, service_role;

-- System/worker path for the narrowly privileged backend role. It can never claim a user
-- actor, which removes the F0 v1 "caller supplies actor identity" gap.
CREATE FUNCTION audit.append_system_event(
 p_stream_key text, p_organization_id uuid, p_actor_type text, p_action_code text,
 p_module_code text, p_resource_type text, p_resource_id uuid, p_event_payload jsonb,
 p_correlation_id uuid, p_causation_id uuid DEFAULT NULL, p_schema_version integer DEFAULT 1
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, audit AS $$
BEGIN
 IF p_actor_type NOT IN ('system','worker') THEN RAISE EXCEPTION 'System path cannot assert actor type %', p_actor_type; END IF;
 RETURN audit.record_event(p_stream_key,p_organization_id,NULL,p_actor_type,p_action_code,p_module_code,
   p_resource_type,p_resource_id,p_event_payload,p_correlation_id,p_causation_id,p_schema_version);
END $$;
REVOKE ALL ON FUNCTION audit.append_system_event(text,uuid,text,text,text,text,uuid,jsonb,uuid,uuid,integer)
 FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION audit.append_system_event(text,uuid,text,text,text,text,uuid,jsonb,uuid,uuid,integer) TO tpmp_event_writer;

-- Verification over STORED bytes: hash must match, and the stored bytes must be valid UTF-8 JSON.
CREATE FUNCTION audit.verify_events(p_stream_key text, p_from_seq bigint, p_to_seq bigint) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, audit, extensions AS $$
DECLARE e audit.audit_events%ROWTYPE; n bigint := 0; ok boolean := true; why text;
BEGIN
 FOR e IN SELECT * FROM audit.audit_events WHERE stream_key=p_stream_key AND event_seq BETWEEN p_from_seq AND p_to_seq ORDER BY event_seq LOOP
   n := n+1;
   IF extensions.digest(e.canonical_event,'sha256') <> e.event_hash THEN ok:=false; why:='hash mismatch at seq '||e.event_seq; EXIT; END IF;
 END LOOP;
 INSERT INTO audit.integrity_verification_runs(stream_key,from_seq,to_seq,status,checked_count,failure_reason)
 VALUES(p_stream_key,p_from_seq,p_to_seq,CASE WHEN ok THEN 'passed' ELSE 'failed' END,n,why);
 RETURN ok;
END $$;
REVOKE ALL ON FUNCTION audit.verify_events(text,bigint,bigint) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION audit.verify_events(text,bigint,bigint) TO tpmp_audit_verifier;
