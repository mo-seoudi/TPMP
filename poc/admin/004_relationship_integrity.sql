-- TPMP POC migration 004: relationship integrity and default-deny validation.
-- Development-only. Run after 003. No client-facing authorization or access grants.
BEGIN;
CREATE OR REPLACE FUNCTION tpmp_admin_poc.validate_relationship_integrity()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, tpmp_admin_poc AS $$
DECLARE source_kind text; target_kind text; parent_id uuid;
BEGIN
 SELECT kind INTO source_kind FROM tpmp_admin_poc.organizations WHERE id=NEW.source_organization_id;
 SELECT kind INTO target_kind FROM tpmp_admin_poc.organizations WHERE id=NEW.target_organization_id;
 IF NEW.relationship_type='group_affiliation' AND
   (source_kind <> 'group' OR target_kind <> 'school') THEN
   RAISE EXCEPTION 'Invalid group affiliation organization types';
 END IF;
 IF NEW.relationship_type='client_supplier' AND
   (source_kind <> 'school' OR target_kind <> 'supplier') THEN
   RAISE EXCEPTION 'Invalid client supplier organization types';
 END IF;
 IF NEW.relationship_type='subcontract' AND
   (source_kind <> 'supplier' OR target_kind <> 'supplier') THEN
   RAISE EXCEPTION 'Invalid subcontract organization types';
 END IF;
 RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_tpmp_validate_relationship ON tpmp_admin_poc.organization_relationships;
CREATE TRIGGER trg_tpmp_validate_relationship
 BEFORE INSERT OR UPDATE OF source_organization_id,target_organization_id,relationship_type
 ON tpmp_admin_poc.organization_relationships FOR EACH ROW
 EXECUTE FUNCTION tpmp_admin_poc.validate_relationship_integrity();

CREATE OR REPLACE FUNCTION tpmp_admin_poc.validate_delegation_integrity()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, tpmp_admin_poc AS $$
DECLARE rel_status text; scope_org uuid;
BEGIN
 SELECT status INTO rel_status FROM tpmp_admin_poc.organization_relationships WHERE id=NEW.relationship_id;
 SELECT scoped_organization_id INTO scope_org FROM tpmp_admin_poc.relationship_scopes WHERE id=NEW.scope_id;
 IF rel_status IS DISTINCT FROM 'active' AND NEW.status='active' THEN
   RAISE EXCEPTION 'Delegation requires active relationship';
 END IF;
 IF scope_org IS DISTINCT FROM NEW.delegator_organization_id AND
    scope_org IS DISTINCT FROM NEW.delegate_organization_id THEN
   RAISE EXCEPTION 'Delegation scope organization must be a relationship party';
 END IF;
 RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_tpmp_validate_delegation ON tpmp_admin_poc.organization_delegations;
CREATE TRIGGER trg_tpmp_validate_delegation
 BEFORE INSERT OR UPDATE ON tpmp_admin_poc.organization_delegations FOR EACH ROW
 EXECUTE FUNCTION tpmp_admin_poc.validate_delegation_integrity();

CREATE OR REPLACE FUNCTION tpmp_admin_poc.validate_user_relationship_grant()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, tpmp_admin_poc AS $$
DECLARE member_org uuid; member_status text; source_org uuid; target_org uuid; rel_status text;
BEGIN
 SELECT organization_id,status INTO member_org,member_status
 FROM tpmp_admin_poc.organization_memberships WHERE id=NEW.membership_id;
 SELECT source_organization_id,target_organization_id,status
 INTO source_org,target_org,rel_status
 FROM tpmp_admin_poc.organization_relationships WHERE id=NEW.relationship_id;
 IF member_org IS DISTINCT FROM source_org AND member_org IS DISTINCT FROM target_org THEN
   RAISE EXCEPTION 'Membership must belong to relationship party';
 END IF;
 IF NEW.status='active' AND
   (member_status IS DISTINCT FROM 'active' OR rel_status IS DISTINCT FROM 'active') THEN
   RAISE EXCEPTION 'Active grant requires active membership and relationship';
 END IF;
 RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_tpmp_validate_user_relationship_grant ON tpmp_admin_poc.relationship_user_grants;
CREATE TRIGGER trg_tpmp_validate_user_relationship_grant
 BEFORE INSERT OR UPDATE ON tpmp_admin_poc.relationship_user_grants FOR EACH ROW
 EXECUTE FUNCTION tpmp_admin_poc.validate_user_relationship_grant();

-- Fail-closed check. Invoker permissions apply, and the POC tables are not
-- accessible to authenticated clients. Trusted API exposure remains future work.
CREATE OR REPLACE FUNCTION tpmp_admin_poc.has_relationship_permission(
 p_relationship_id uuid, p_permission_code text
) RETURNS boolean LANGUAGE sql STABLE SECURITY INVOKER
 SET search_path = pg_catalog, tpmp_admin_poc AS $$
 SELECT EXISTS (
   SELECT 1 FROM tpmp_admin_poc.relationship_user_grants g
   JOIN tpmp_admin_poc.organization_memberships m ON m.id=g.membership_id
   JOIN tpmp_admin_poc.organization_relationships r ON r.id=g.relationship_id
   JOIN tpmp_admin_poc.roles role ON role.organization_id=m.organization_id
   JOIN tpmp_admin_poc.role_permissions rp ON rp.role_id=role.id
   WHERE m.user_id=auth.uid() AND m.status='active'
     AND g.relationship_id=p_relationship_id AND g.permission_code=p_permission_code
     AND rp.permission_code=p_permission_code
     AND g.status='active' AND r.status='active'
     AND g.valid_from<=now() AND (g.valid_until IS NULL OR g.valid_until>now())
     AND (r.effective_from<=now()) AND (r.effective_until IS NULL OR r.effective_until>now())
     AND g.revoked_at IS NULL
     AND EXISTS (
       SELECT 1 FROM tpmp_admin_poc.user_school_role_grants sg
       WHERE sg.membership_id=m.id AND sg.role_id=role.id
         AND sg.revoked_at IS NULL
         AND sg.school_id=r.source_organization_id
     )
 );
$$;
-- Do not expose this incomplete prototype checker to client roles.
REVOKE ALL ON FUNCTION tpmp_admin_poc.has_relationship_permission(uuid,text)
 FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.validate_relationship_integrity()
 FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.validate_delegation_integrity()
 FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.validate_user_relationship_grant()
 FROM PUBLIC, anon, authenticated;
COMMIT;
