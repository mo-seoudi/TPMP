-- TPMP Admin POC Stage 2: permission catalog and organization-scoped role seeds.
-- REVIEWED DEVELOPMENT POC ONLY. No users, memberships, grants or RLS policies created.
-- Apply only after poc/admin/001_admin_access_foundation.sql.
-- Repeatable: ON CONFLICT keeps existing descriptions and role assignments unchanged.
begin;
insert into tpmp_admin_poc.permissions (code, description) values
 ('users.view','View authorized user directory'),
 ('users.invite','Invite users within delegated scope'),
 ('users.manage','Manage authorized users and access grants'),
 ('roles.view','View roles and permissions'),
 ('roles.manage','Manage delegated role definitions'),
 ('organizations.view','View authorized organizations and schools'),
 ('workspaces.view','View authorized workspaces'),
 ('suppliers.view','View supplier relationships'),
 ('suppliers.manage','Maintain authorized supplier records'),
 ('personnel.view','View authorized personnel'),
 ('personnel.manage','Maintain authorized personnel records'),
 ('documents.view','View authorized documents'),
 ('documents.upload','Upload or replace documents for authorized records'),
 ('documents.review','Review submitted document versions'),
 ('compliance.view','View compliance status and requirements'),
 ('compliance.manage','Maintain compliance requirements and exceptions'),
 ('approvals.review','Approve or reject authorized submissions'),
 ('contracts.view','View authorized contracts'),
 ('contracts.manage','Maintain authorized contracts'),
 ('reports.view','View authorized reporting'),
 ('audit.view','View authorized audit history')
on conflict (code) do nothing;

-- Roles are tenant/organization owned. Only seed roles for existing organizations
-- with a matching kind; this does NOT assign roles to anyone.
-- Run this block again when new organizations are provisioned, or implement a
-- trusted server-side provisioning command later.
insert into tpmp_admin_poc.roles (organization_id,code,name)
select o.id, v.code, v.name
from tpmp_admin_poc.organizations o
join (values
 ('group','organization_admin','Organization Administrator'),
 ('group','group_operations','Group Operations'),
 ('group','group_compliance','Group Compliance Reviewer'),
 ('school','school_admin','School Administrator'),
 ('school','school_reviewer','School Reviewer'),
 ('school','school_staff','School Staff'),
 ('supplier','supplier_admin','Supplier Administrator'),
 ('supplier','supplier_staff','Supplier Staff')
) as v(kind,code,name) on v.kind=o.kind
on conflict (organization_id,code) do nothing;

-- Explicit role-permission matrix. No user access is created here.
with matrix(role_code, permission_code) as (
 values
 ('organization_admin','users.view'),('organization_admin','users.invite'),
 ('organization_admin','users.manage'),('organization_admin','roles.view'),
 ('organization_admin','organizations.view'),('organization_admin','workspaces.view'),
 ('organization_admin','suppliers.view'),('organization_admin','suppliers.manage'),
 ('organization_admin','personnel.view'),('organization_admin','personnel.manage'),
 ('organization_admin','documents.view'),('organization_admin','documents.upload'),
 ('organization_admin','documents.review'),('organization_admin','compliance.view'),
 ('organization_admin','compliance.manage'),('organization_admin','approvals.review'),
 ('organization_admin','contracts.view'),('organization_admin','contracts.manage'),
 ('organization_admin','reports.view'),('organization_admin','audit.view'),
 ('group_operations','organizations.view'),('group_operations','workspaces.view'),
 ('group_operations','suppliers.view'),('group_operations','suppliers.manage'),
 ('group_operations','personnel.view'),('group_operations','personnel.manage'),
 ('group_operations','documents.view'),('group_operations','documents.upload'),
 ('group_operations','compliance.view'),('group_operations','contracts.view'),
 ('group_operations','reports.view'),
 ('group_compliance','workspaces.view'),('group_compliance','suppliers.view'),
 ('group_compliance','personnel.view'),('group_compliance','documents.view'),
 ('group_compliance','documents.review'),('group_compliance','compliance.view'),
 ('group_compliance','approvals.review'),('group_compliance','reports.view'),
 ('school_admin','users.view'),('school_admin','users.invite'),
 ('school_admin','users.manage'),('school_admin','roles.view'),
 ('school_admin','workspaces.view'),('school_admin','suppliers.view'),
 ('school_admin','suppliers.manage'),('school_admin','personnel.view'),
 ('school_admin','personnel.manage'),('school_admin','documents.view'),
 ('school_admin','documents.upload'),('school_admin','documents.review'),
 ('school_admin','compliance.view'),('school_admin','compliance.manage'),
 ('school_admin','approvals.review'),('school_admin','contracts.view'),
 ('school_admin','contracts.manage'),('school_admin','reports.view'),
 ('school_admin','audit.view'),
 ('school_reviewer','workspaces.view'),('school_reviewer','suppliers.view'),
 ('school_reviewer','personnel.view'),('school_reviewer','documents.view'),
 ('school_reviewer','documents.review'),('school_reviewer','compliance.view'),
 ('school_reviewer','approvals.review'),
 ('school_staff','workspaces.view'),('school_staff','suppliers.view'),
 ('school_staff','personnel.view'),('school_staff','documents.view'),
 ('school_staff','documents.upload'),('school_staff','compliance.view'),
 ('supplier_admin','suppliers.view'),('supplier_admin','suppliers.manage'),
 ('supplier_admin','personnel.view'),('supplier_admin','personnel.manage'),
 ('supplier_admin','documents.view'),('supplier_admin','documents.upload'),
 ('supplier_admin','compliance.view'),
 ('supplier_staff','suppliers.view'),('supplier_staff','personnel.view'),
 ('supplier_staff','documents.view'),('supplier_staff','documents.upload'),
 ('supplier_staff','compliance.view')
)
insert into tpmp_admin_poc.role_permissions(role_id,permission_code)
select r.id, m.permission_code
from tpmp_admin_poc.roles r
join matrix m on m.role_code=r.code
join tpmp_admin_poc.permissions p on p.code=m.permission_code
on conflict do nothing;
commit;
