-- TPMP F0 development: controlled organization creation and supplier onboarding.
-- Requires 001-007; run in SQL Editor before connecting the Vercel API.
-- Security definer functions are deliberately NOT exposed to browser roles.
BEGIN;
CREATE OR REPLACE FUNCTION tpmp_admin_poc.admin_create_organization(
 p_actor uuid,p_name text,p_kind text,p_parent uuid DEFAULT NULL,p_category text DEFAULT NULL
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,tpmp_admin_poc
AS $$
DECLARE v_id uuid;
BEGIN
 IF p_actor IS NULL OR NOT EXISTS(
  SELECT 1 FROM tpmp_admin_poc.platform_administrators
  WHERE user_id=p_actor AND status='active' AND revoked_at IS NULL
 ) THEN RAISE EXCEPTION 'Platform administrator required' USING ERRCODE='42501'; END IF;
 IF length(btrim(coalesce(p_name,''))) NOT BETWEEN 1 AND 200
   OR p_kind NOT IN ('group','school','supplier') THEN
   RAISE EXCEPTION 'Invalid organization input' USING ERRCODE='22023';
 END IF;
 IF p_kind <> 'school' AND p_parent IS NOT NULL THEN
   RAISE EXCEPTION 'Only schools can have parent groups' USING ERRCODE='22023';
 END IF;
 IF p_parent IS NOT NULL AND NOT EXISTS(
   SELECT 1 FROM tpmp_admin_poc.organizations WHERE id=p_parent AND kind='group'
 ) THEN RAISE EXCEPTION 'Parent must be a group' USING ERRCODE='22023'; END IF;
 IF EXISTS(SELECT 1 FROM tpmp_admin_poc.organizations WHERE lower(name)=lower(btrim(p_name))) THEN
   RAISE EXCEPTION 'Organization name already exists' USING ERRCODE='23505';
 END IF;
 INSERT INTO tpmp_admin_poc.organizations(name,kind,parent_organization_id)
 VALUES(btrim(p_name),p_kind,p_parent) RETURNING id INTO v_id;
 RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION tpmp_admin_poc.admin_link_school_supplier(
 p_actor uuid,p_school uuid,p_supplier uuid
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,tpmp_admin_poc
AS $$
DECLARE v_id uuid;
BEGIN
 IF p_actor IS NULL OR NOT EXISTS(
  SELECT 1 FROM tpmp_admin_poc.platform_administrators
  WHERE user_id=p_actor AND status='active' AND revoked_at IS NULL
 ) THEN RAISE EXCEPTION 'Platform administrator required' USING ERRCODE='42501'; END IF;
 IF NOT EXISTS(SELECT 1 FROM tpmp_admin_poc.organizations WHERE id=p_school AND kind='school')
 OR NOT EXISTS(SELECT 1 FROM tpmp_admin_poc.organizations WHERE id=p_supplier AND kind='supplier') THEN
  RAISE EXCEPTION 'A school and a supplier are required' USING ERRCODE='22023';
 END IF;
 SELECT id INTO v_id FROM tpmp_admin_poc.organization_relationships
 WHERE source_organization_id=p_school AND target_organization_id=p_supplier
 AND relationship_type='client_supplier' AND status='active'
 AND (effective_until IS NULL OR effective_until>now())
 LIMIT 1;
 IF v_id IS NOT NULL THEN RETURN v_id; END IF;
 INSERT INTO tpmp_admin_poc.organization_relationships
 (source_organization_id,target_organization_id,relationship_type,status)
 VALUES(p_school,p_supplier,'client_supplier','active')
 RETURNING id INTO v_id;
 RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION tpmp_admin_poc.admin_register_supplier_for_school(
 p_actor uuid,p_school uuid,p_name text
) RETURNS TABLE(supplier_id uuid,relationship_id uuid)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,tpmp_admin_poc
AS $$
DECLARE v_supplier uuid; v_rel uuid;
BEGIN
 -- Serialize name checks across concurrent requests.
 PERFORM pg_advisory_xact_lock(hashtextextended(lower(btrim(coalesce(p_name,''))),42));
 IF NOT EXISTS(SELECT 1 FROM tpmp_admin_poc.platform_administrators
  WHERE user_id=p_actor AND status='active' AND revoked_at IS NULL) THEN
  RAISE EXCEPTION 'Platform administrator required' USING ERRCODE='42501';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM tpmp_admin_poc.organizations WHERE id=p_school AND kind='school')
 OR length(btrim(coalesce(p_name,''))) NOT BETWEEN 1 AND 200 THEN
  RAISE EXCEPTION 'Invalid school or supplier name' USING ERRCODE='22023';
 END IF;
 -- Reuse is intentionally manual: ambiguous legal identities must be reviewed.
 IF EXISTS(SELECT 1 FROM tpmp_admin_poc.organizations WHERE lower(name)=lower(btrim(p_name))) THEN
  RAISE EXCEPTION 'Organization already exists; link existing supplier after identity review' USING ERRCODE='23505';
 END IF;
 INSERT INTO tpmp_admin_poc.organizations(name,kind)
 VALUES(btrim(p_name),'supplier') RETURNING id INTO v_supplier;
 INSERT INTO tpmp_admin_poc.organization_relationships
 (source_organization_id,target_organization_id,relationship_type,status)
 VALUES(p_school,v_supplier,'client_supplier','active') RETURNING id INTO v_rel;
 RETURN QUERY SELECT v_supplier,v_rel;
END $$;

-- No browser roles or generic public execution.
REVOKE ALL ON FUNCTION tpmp_admin_poc.admin_create_organization(uuid,text,text,uuid,text) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.admin_link_school_supplier(uuid,uuid,uuid) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION tpmp_admin_poc.admin_register_supplier_for_school(uuid,uuid,text) FROM PUBLIC,anon,authenticated;
COMMIT;
