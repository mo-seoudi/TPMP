-- TPMP Stage 11: one-time platform super admin bootstrap (development only).
-- Run in Supabase SQL Editor after creating your own Auth user.
-- This does NOT grant privileges to anon/authenticated or expose any API.
BEGIN;
CREATE TABLE IF NOT EXISTS tpmp_admin_poc.platform_administrators (
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
 status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','revoked')),
 created_at timestamptz NOT NULL DEFAULT now(),
 revoked_at timestamptz,
 CHECK (status <> 'revoked' OR revoked_at IS NOT NULL)
);
ALTER TABLE tpmp_admin_poc.platform_administrators ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON tpmp_admin_poc.platform_administrators FROM PUBLIC,anon,authenticated;
-- Replace email with your exact Supabase Auth email before executing.
-- The count guard prevents silently assigning multiple or nonexistent accounts.
DO $$
DECLARE v_email text := 'REPLACE_WITH_YOUR_EMAIL';
DECLARE v_user_id uuid;
BEGIN
 SELECT id INTO STRICT v_user_id
 FROM auth.users
 WHERE lower(email)=lower(v_email);
 INSERT INTO tpmp_admin_poc.platform_administrators(user_id,status)
 VALUES (v_user_id,'active')
 ON CONFLICT (user_id) DO NOTHING;
END $$;
COMMIT;
-- Verify (read-only):
-- SELECT u.email,p.status FROM tpmp_admin_poc.platform_administrators p
-- JOIN auth.users u ON u.id=p.user_id;
