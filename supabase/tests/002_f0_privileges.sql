-- No browser-facing or generic role can reach audit/automation; each internal role gets only its own functions.
BEGIN;
DO $$ DECLARE r text; f record; t record; s text; BEGIN
  FOREACH r IN ARRAY ARRAY['anon','authenticated','service_role','public'] LOOP
    FOREACH s IN ARRAY ARRAY['audit','automation','platform','registry','tenant','security','identity','compliance','documents','contracts','workflow','integration','reporting'] LOOP
      PERFORM tst.assert(NOT has_schema_privilege(r,s,'USAGE'), r||' has USAGE on '||s);
    END LOOP;
    FOR f IN SELECT p.oid::regprocedure AS sig FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname IN ('audit','automation') LOOP
      PERFORM tst.assert(NOT has_function_privilege(r,f.sig,'EXECUTE'), r||' can execute '||f.sig);
    END LOOP;
    FOR t IN SELECT format('%I.%I',schemaname,tablename) AS q FROM pg_tables WHERE schemaname IN ('audit','automation') LOOP
      PERFORM tst.assert(NOT has_table_privilege(r,t.q,'SELECT') AND NOT has_table_privilege(r,t.q,'INSERT')
        AND NOT has_table_privilege(r,t.q,'UPDATE') AND NOT has_table_privilege(r,t.q,'DELETE'), r||' has table privilege on '||t.q);
    END LOOP;
  END LOOP;
END $$;
-- Matrix of which internal role may execute which function.
DO $$ DECLARE f record; allowed text[]; r text; expect boolean; BEGIN
  FOR f IN SELECT p.oid::regprocedure AS sig, p.proname AS name FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname IN ('audit','automation') AND p.prokind='f' LOOP
    FOREACH r IN ARRAY ARRAY['tpmp_event_writer','tpmp_outbox_worker','tpmp_audit_verifier'] LOOP
      expect := CASE r
        WHEN 'tpmp_event_writer' THEN f.name IN ('append_system_event','enqueue_event')
        WHEN 'tpmp_outbox_worker' THEN f.name IN ('claim_messages','get_message_payload','complete_message','fail_message','purge_completed')
        WHEN 'tpmp_audit_verifier' THEN f.name IN ('verify_events') END;
      PERFORM tst.assert(has_function_privilege(r,f.sig,'EXECUTE')=expect, r||' execute on '||f.sig||' expected '||expect);
    END LOOP;
  END LOOP;
END $$;
-- Internal roles have no direct table writes.
DO $$ BEGIN
  PERFORM tst.assert(NOT has_table_privilege('tpmp_event_writer','audit.audit_events','INSERT'),'event_writer cannot insert audit rows directly');
  PERFORM tst.assert(NOT has_table_privilege('tpmp_outbox_worker','automation.outbox_messages','UPDATE'),'worker cannot update outbox rows directly');
END $$;
ROLLBACK;
