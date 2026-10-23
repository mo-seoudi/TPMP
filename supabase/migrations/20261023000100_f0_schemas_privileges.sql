-- F0.001 (revised per A-01 / D-22): internal schemas and default-deny privileges.
-- Reserved module namespaces create no tables here. Browser roles never receive
-- access to audit or automation; user commands reach them only through
-- SECURITY DEFINER functions (D-22).
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS automation;
CREATE SCHEMA IF NOT EXISTS platform;
CREATE SCHEMA IF NOT EXISTS registry;
CREATE SCHEMA IF NOT EXISTS tenant;
CREATE SCHEMA IF NOT EXISTS security;
CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS compliance;
CREATE SCHEMA IF NOT EXISTS documents;
CREATE SCHEMA IF NOT EXISTS contracts;
CREATE SCHEMA IF NOT EXISTS workflow;
CREATE SCHEMA IF NOT EXISTS integration;
CREATE SCHEMA IF NOT EXISTS reporting;

DO $$ BEGIN
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='tpmp_event_writer') THEN CREATE ROLE tpmp_event_writer NOLOGIN NOINHERIT; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='tpmp_outbox_worker') THEN CREATE ROLE tpmp_outbox_worker NOLOGIN NOINHERIT; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='tpmp_audit_verifier') THEN CREATE ROLE tpmp_audit_verifier NOLOGIN NOINHERIT; END IF;
END $$;

-- No module schema is reachable by browser roles unless a later migration grants it deliberately.
REVOKE ALL ON SCHEMA audit, automation, platform, registry, tenant, security, identity,
  compliance, documents, contracts, workflow, integration, reporting
  FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA audit TO tpmp_event_writer, tpmp_audit_verifier;
GRANT USAGE ON SCHEMA automation TO tpmp_event_writer, tpmp_outbox_worker;

-- Functions are not executable by PUBLIC by default in these schemas.
ALTER DEFAULT PRIVILEGES IN SCHEMA audit REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA automation REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA automation REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
