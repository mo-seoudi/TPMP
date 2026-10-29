-- TPMP Stage 10 / POC 006: fail-closed scope checks and relationship validation
-- Development-only; additive; requires 001-005.
-- No client EXECUTE grants. This is not the final trusted authorization API.
BEGIN;

-- Ensure relationship scopes cannot point to unrelated organizations.
CREATE OR REPLACE FUNCTION tpmp_admin_poc.validate_relationship_scope()
RETURNS trigger LANGUAGE plpgsql
SET search_path=pg_catalog,tpmp_admin_poc AS $$
DECLARE v_source uuid; v_target uuid;
BEGIN
 SELECT source_organization_id,target_organization_id
 INTO v_source,v_target
 FROM tpmp_admin_poc.organization_relationships
 WHERE id=NEW.relationship_id;
 IF NEW.scoped_organization_id IS DISTINCT FROM v_source
    AND NEW.scoped_organization_id IS DISTINCT FROM v_target THEN
   RAISE EXCEPTION 'Scope organization must be a relationship party';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_tpmp_validate_relationship_scope
 BEFORE INSERT OR UPDATE ON tpmp_admin_poc.relationship_scopes
 FOR EACH ROW EXECUTE FUNCTION tpmp_admin_poc.validate_relationship_scope();

-- A scoped grant must match the requested scope exactly.
-- A NULL scope on a grant is NOT treated as a wildcard.
-- No cross-relationship inheritance or delegation expansion.
CREATE OR REPLACE FUNCTION tpmp_admin_poc.has_scoped_relationship_permission(
 p_relationship_id uuid,
 p_permission_code text,
 p_scope_id uuid
) RETURNS boolean
LANGUAGE sql STABLE SECURITY INVOKER
SET search_path=pg_catalog,tpmp_admin_poc AS $$
 SELECT p_scope_id IS NOT NULL AND EXISTS (
  SELECT 1
  FROM tpmp_admin_poc.organization_memberships m
  JOIN tpmp_admin_poc.user_role_assignments ura
    ON ura.membership_id=m.id
  JOIN tpmp_admin_poc.roles ro
    ON ro.id=ura.role_id AND ro.organization_id=m.organization_id
  JOIN tpmp_admin_poc.role_permissions rp
    ON rp.role_id=ro.id AND rp.permission_code=p_permission_code
  JOIN tpmp_admin_poc.relationship_user_grants rug
    ON rug.membership_id=m.id
   AND rug.permission_code=p_permission_code
   AND rug.relationship_id=p_relationship_id
   AND rug.scope_id=p_scope_id
  JOIN tpmp_admin_poc.relationship_scopes sc
    ON sc.id=rug.scope_id AND sc.relationship_id=rug.relationship_id
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
 );
$$;

-- Prevent accidental use of the earlier unscoped checker as an authorization
-- decision. The older signature is retained for compatibility but fails closed.
CREATE OR REPLACE FUNCTION tpmp_admin_poc.has_relationship_permission(
 p_relationship_id uuid,p_permission_code text
) RETURNS boolean
LANGUAGE sql STABLE SECURITY INVOKER
SET search_path=pg_catalog,tpmp_admin_poc AS $$
 SELECT false;
$$;

-- All POC functions and tables remain inaccessible to client roles.
REVOKE ALL ON FUNCTION tpmp_admin_poc.has_scoped_relationship_permission(uuid,text,uuid)
 FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.has_relationship_permission(uuid,text)
 FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.validate_relationship_scope()
 FROM PUBLIC,anon,authenticated;
COMMIT;
