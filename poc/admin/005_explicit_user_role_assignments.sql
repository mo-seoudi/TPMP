-- TPMP Stage 8 POC: explicit user role assignments and fail-closed checker.
-- Requires 001-004. Development only; no client grants, no production authorization.
-- This migration is additive. It does not create Auth users or grant permissions.
BEGIN;
CREATE TABLE tpmp_admin_poc.user_role_assignments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 membership_id uuid NOT NULL REFERENCES tpmp_admin_poc.organization_memberships(id),
 role_id uuid NOT NULL REFERENCES tpmp_admin_poc.roles(id),
 status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','active','suspended','revoked')),
 valid_from timestamptz NOT NULL DEFAULT now(),
 valid_until timestamptz,
 revoked_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 revision bigint NOT NULL DEFAULT 1 CHECK (revision > 0),
 CHECK (valid_until IS NULL OR valid_until > valid_from),
 CHECK (status <> 'revoked' OR revoked_at IS NOT NULL)
);
CREATE UNIQUE INDEX uq_tpmp_active_role_assignment
 ON tpmp_admin_poc.user_role_assignments(membership_id,role_id)
 WHERE status='active' AND revoked_at IS NULL;
CREATE INDEX idx_tpmp_role_assignment_membership
 ON tpmp_admin_poc.user_role_assignments(membership_id,status);

-- Explicit integrity: a role may only be assigned to a membership in the
-- SAME organization. No group-to-child inheritance.
CREATE OR REPLACE FUNCTION tpmp_admin_poc.validate_user_role_assignment()
RETURNS trigger LANGUAGE plpgsql
SET search_path = pg_catalog, tpmp_admin_poc AS $$
DECLARE member_org uuid; member_status text; role_org uuid;
BEGIN
 SELECT organization_id,status INTO member_org,member_status
 FROM tpmp_admin_poc.organization_memberships WHERE id=NEW.membership_id;
 SELECT organization_id INTO role_org
 FROM tpmp_admin_poc.roles WHERE id=NEW.role_id;
 IF member_org IS DISTINCT FROM role_org THEN
   RAISE EXCEPTION 'Role organization must match membership organization';
 END IF;
 IF NEW.status='active' AND member_status IS DISTINCT FROM 'active' THEN
   RAISE EXCEPTION 'Active role requires active membership';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_tpmp_validate_user_role_assignment
 BEFORE INSERT OR UPDATE ON tpmp_admin_poc.user_role_assignments
 FOR EACH ROW EXECUTE FUNCTION tpmp_admin_poc.validate_user_role_assignment();

-- Replace the preliminary checker, which incorrectly accepted a role merely
-- because it existed in an organization.
-- A relationship grant is necessary, but not sufficient: matching active role
-- assignment, active membership, valid relationship and permission are required.
-- This checker deliberately does NOT implement resource-level/document grants,
-- delegated authority, trusted admin commands or audit. It is not exposed.
CREATE OR REPLACE FUNCTION tpmp_admin_poc.has_relationship_permission(
 p_relationship_id uuid, p_permission_code text
) RETURNS boolean LANGUAGE sql STABLE SECURITY INVOKER
SET search_path = pg_catalog, tpmp_admin_poc AS $$
 SELECT COALESCE(EXISTS (
  SELECT 1
  FROM tpmp_admin_poc.organization_memberships m
  JOIN tpmp_admin_poc.user_role_assignments ura
    ON ura.membership_id=m.id
  JOIN tpmp_admin_poc.roles role
    ON role.id=ura.role_id AND role.organization_id=m.organization_id
  JOIN tpmp_admin_poc.role_permissions rp
    ON rp.role_id=role.id AND rp.permission_code=p_permission_code
  JOIN tpmp_admin_poc.relationship_user_grants rug
    ON rug.membership_id=m.id
   AND rug.permission_code=p_permission_code
   AND rug.relationship_id=p_relationship_id
  JOIN tpmp_admin_poc.organization_relationships rel
    ON rel.id=rug.relationship_id
  WHERE m.user_id=auth.uid()
    AND m.status='active'
    AND ura.status='active' AND ura.revoked_at IS NULL
    AND ura.valid_from<=now()
    AND (ura.valid_until IS NULL OR ura.valid_until>now())
    AND rug.status='active' AND rug.revoked_at IS NULL
    AND rug.valid_from<=now()
    AND (rug.valid_until IS NULL OR rug.valid_until>now())
    AND rel.status='active'
    AND rel.effective_from<=now()
    AND (rel.effective_until IS NULL OR rel.effective_until>now())
    AND m.organization_id IN (rel.source_organization_id,rel.target_organization_id)
    AND (rug.scope_id IS NULL OR EXISTS (
       SELECT 1 FROM tpmp_admin_poc.relationship_scopes s
       WHERE s.id=rug.scope_id AND s.relationship_id=rel.id
    ))
 ),false);
$$;
ALTER TABLE tpmp_admin_poc.user_role_assignments ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON tpmp_admin_poc.user_role_assignments FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.has_relationship_permission(uuid,text)
 FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.validate_user_role_assignment()
 FROM PUBLIC, anon, authenticated;
COMMIT;
