-- Test-only stand-in for Supabase-provided objects (roles, auth.uid()).
DO $$ BEGIN
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN BYPASSRLS; END IF;
END $$;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('request.jwt.claim.sub', true),'')::uuid $$;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;

-- Test helpers (never shipped as migrations).
CREATE SCHEMA IF NOT EXISTS tst;
GRANT USAGE ON SCHEMA tst TO PUBLIC;
-- Fails the test unless the statement raises an error when run as the current role.
CREATE OR REPLACE FUNCTION tst.denied(p_sql text, p_label text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  BEGIN EXECUTE p_sql; EXCEPTION WHEN OTHERS THEN RETURN; END;
  RAISE EXCEPTION 'EXPECTED DENIAL but succeeded: %', p_label;
END $$;
CREATE OR REPLACE FUNCTION tst.assert(p_ok boolean, p_label text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF p_ok IS NOT TRUE THEN RAISE EXCEPTION 'ASSERTION FAILED: %', p_label; END IF; END $$;
GRANT EXECUTE ON FUNCTION tst.denied(text,text), tst.assert(boolean,text) TO PUBLIC;
