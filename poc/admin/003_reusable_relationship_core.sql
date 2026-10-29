-- TPMP reusable organization/partnership core, development POC migration 003.
-- ADDITIVE: preserves existing nine tables, roles, permissions, and demo records.
-- Run only after 001 and 002 in tpmp-dev. Not production-ready authorization.
BEGIN;
CREATE TABLE IF NOT EXISTS tpmp_admin_poc.organization_relationships (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 source_organization_id uuid NOT NULL REFERENCES tpmp_admin_poc.organizations(id),
 target_organization_id uuid NOT NULL REFERENCES tpmp_admin_poc.organizations(id),
 relationship_type text NOT NULL CHECK (relationship_type IN ('group_affiliation','client_supplier','subcontract','service_partnership','other')),
 status text NOT NULL DEFAULT 'active' CHECK (status IN ('draft','active','suspended','ended')),
 effective_from timestamptz NOT NULL DEFAULT now(),
 effective_until timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK (source_organization_id <> target_organization_id),
 CHECK (effective_until IS NULL OR effective_until > effective_from),
 UNIQUE (id, source_organization_id, target_organization_id)
);
CREATE INDEX IF NOT EXISTS idx_tpmp_rel_source ON tpmp_admin_poc.organization_relationships(source_organization_id,status);
CREATE INDEX IF NOT EXISTS idx_tpmp_rel_target ON tpmp_admin_poc.organization_relationships(target_organization_id,status);
CREATE UNIQUE INDEX IF NOT EXISTS uq_tpmp_rel_active_pair
 ON tpmp_admin_poc.organization_relationships(source_organization_id,target_organization_id,relationship_type)
 WHERE status = 'active' AND effective_until IS NULL;

-- Resource scopes are explicit; no implicit expansion to subsidiaries or subcontractors.
CREATE TABLE IF NOT EXISTS tpmp_admin_poc.relationship_scopes (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 relationship_id uuid NOT NULL REFERENCES tpmp_admin_poc.organization_relationships(id),
 scoped_organization_id uuid NOT NULL REFERENCES tpmp_admin_poc.organizations(id),
 scope_type text NOT NULL CHECK (scope_type IN ('organization','engagement','location','resource')),
 resource_reference text,
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK ((scope_type = 'organization' AND resource_reference IS NULL) OR
        (scope_type <> 'organization' AND resource_reference IS NOT NULL)),
 UNIQUE (relationship_id, scoped_organization_id, scope_type, resource_reference)
);
-- A delegation is a record of proposed/approved authority, NOT executable authorization.
CREATE TABLE IF NOT EXISTS tpmp_admin_poc.organization_delegations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 relationship_id uuid NOT NULL,
 delegator_organization_id uuid NOT NULL,
 delegate_organization_id uuid NOT NULL,
 scope_id uuid NOT NULL REFERENCES tpmp_admin_poc.relationship_scopes(id),
 permission_code text NOT NULL REFERENCES tpmp_admin_poc.permissions(code),
 status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','active','suspended','revoked','expired')),
 valid_from timestamptz NOT NULL DEFAULT now(),
 valid_until timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 revoked_at timestamptz,
 CHECK (delegator_organization_id <> delegate_organization_id),
 CHECK (valid_until IS NULL OR valid_until > valid_from),
 CHECK (status <> 'revoked' OR revoked_at IS NOT NULL),
 FOREIGN KEY (relationship_id, delegator_organization_id, delegate_organization_id)
 REFERENCES tpmp_admin_poc.organization_relationships(id,source_organization_id,target_organization_id)
);
CREATE INDEX IF NOT EXISTS idx_tpmp_delegations_delegate
 ON tpmp_admin_poc.organization_delegations(delegate_organization_id,status);
-- Explicit person-to-relationship role assignment. Membership organization
-- alignment and delegated authorization require trusted command validation later.
CREATE TABLE IF NOT EXISTS tpmp_admin_poc.relationship_user_grants (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 membership_id uuid NOT NULL REFERENCES tpmp_admin_poc.organization_memberships(id),
 relationship_id uuid NOT NULL REFERENCES tpmp_admin_poc.organization_relationships(id),
 permission_code text NOT NULL REFERENCES tpmp_admin_poc.permissions(code),
 scope_id uuid REFERENCES tpmp_admin_poc.relationship_scopes(id),
 status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','active','suspended','revoked')),
 valid_from timestamptz NOT NULL DEFAULT now(),
 valid_until timestamptz,
 revoked_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK (valid_until IS NULL OR valid_until > valid_from),
 CHECK (status <> 'revoked' OR revoked_at IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_tpmp_relationship_grants_membership
 ON tpmp_admin_poc.relationship_user_grants(membership_id,status);
-- Ensure scope references belong to the same relationship, even before
-- privileged command functions are implemented.
CREATE UNIQUE INDEX IF NOT EXISTS uq_tpmp_rel_scope_id_rel
 ON tpmp_admin_poc.relationship_scopes(id,relationship_id);
ALTER TABLE tpmp_admin_poc.organization_delegations
 ADD CONSTRAINT fk_tpmp_delegation_scope_relationship
 FOREIGN KEY (scope_id,relationship_id)
 REFERENCES tpmp_admin_poc.relationship_scopes(id,relationship_id);
ALTER TABLE tpmp_admin_poc.relationship_user_grants
 ADD CONSTRAINT fk_tpmp_user_grant_scope_relationship
 FOREIGN KEY (scope_id,relationship_id)
 REFERENCES tpmp_admin_poc.relationship_scopes(id,relationship_id);
-- Backfill existing demo parent-child and supplier-school edges.
INSERT INTO tpmp_admin_poc.organization_relationships
 (source_organization_id,target_organization_id,relationship_type,status)
SELECT parent_organization_id,id,'group_affiliation','active'
FROM tpmp_admin_poc.organizations
WHERE parent_organization_id IS NOT NULL
ON CONFLICT DO NOTHING;
INSERT INTO tpmp_admin_poc.organization_relationships
 (source_organization_id,target_organization_id,relationship_type,status)
SELECT school_id,supplier_id,'client_supplier',status
FROM tpmp_admin_poc.supplier_relationships
WHERE status='active'
ON CONFLICT DO NOTHING;
-- Default-deny: no policies, no grants to anon/authenticated.
ALTER TABLE tpmp_admin_poc.organization_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpmp_admin_poc.relationship_scopes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpmp_admin_poc.organization_delegations ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpmp_admin_poc.relationship_user_grants ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON tpmp_admin_poc.organization_relationships,
 tpmp_admin_poc.relationship_scopes,
 tpmp_admin_poc.organization_delegations,
 tpmp_admin_poc.relationship_user_grants FROM PUBLIC, anon, authenticated;
COMMIT;
