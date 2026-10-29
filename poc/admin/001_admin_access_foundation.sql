-- TPMP Admin access foundation: ISOLATED DEVELOPMENT PROTOTYPE ONLY
-- Not a production migration. Requires Supabase Auth; apply in disposable dev DB after review.
-- No frontend/anon/authenticated direct table grants are provided.
-- No SECURITY DEFINER functions or privilege bypass are created.
begin;
create schema if not exists tpmp_admin_poc;
revoke all on schema tpmp_admin_poc from public, anon, authenticated;
create table tpmp_admin_poc.organizations (
 id uuid primary key default gen_random_uuid(),
 name text not null check (length(btrim(name)) between 1 and 200),
 kind text not null check (kind in ('group','school','supplier')),
 parent_organization_id uuid references tpmp_admin_poc.organizations(id),
 created_at timestamptz not null default now(),
 constraint ck_org_no_self_parent check (parent_organization_id is distinct from id)
);
create index idx_admin_org_parent on tpmp_admin_poc.organizations(parent_organization_id);
create table tpmp_admin_poc.user_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null check (length(btrim(display_name)) between 1 and 200),
 created_at timestamptz not null default now()
);
create table tpmp_admin_poc.organization_memberships (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id),
 organization_id uuid not null references tpmp_admin_poc.organizations(id),
 status text not null default 'active' check (status in ('active','suspended','revoked')),
 created_at timestamptz not null default now(),
 revoked_at timestamptz,
 unique (user_id, organization_id),
 constraint ck_membership_revocation check (status <> 'revoked' or revoked_at is not null)
);
create index idx_admin_memberships_user on tpmp_admin_poc.organization_memberships(user_id,status);
create table tpmp_admin_poc.permissions (
 code text primary key check (code ~ '^[a-z][a-z0-9_.]{2,99}$'),
 description text not null
);
create table tpmp_admin_poc.roles (
 id uuid primary key default gen_random_uuid(),
 organization_id uuid not null references tpmp_admin_poc.organizations(id),
 code text not null check (code ~ '^[a-z][a-z0-9_]{1,63}$'),
 name text not null,
 unique(id,organization_id),
 unique(organization_id,code)
);
create table tpmp_admin_poc.role_permissions (
 role_id uuid not null references tpmp_admin_poc.roles(id) on delete cascade,
 permission_code text not null references tpmp_admin_poc.permissions(code),
 primary key(role_id,permission_code)
);
-- Each grant targets a real organization via FK; no implicit parent/child inheritance.
create table tpmp_admin_poc.user_school_role_grants (
 id uuid primary key default gen_random_uuid(),
 membership_id uuid not null references tpmp_admin_poc.organization_memberships(id),
 role_id uuid not null,
 role_organization_id uuid not null,
 school_id uuid not null references tpmp_admin_poc.organizations(id),
 granted_at timestamptz not null default now(),
 revoked_at timestamptz,
 granted_by uuid not null references auth.users(id),
 revision bigint not null default 1 check (revision > 0),
 foreign key(role_id,role_organization_id) references tpmp_admin_poc.roles(id,organization_id),
 constraint ck_school_grant_time check (revoked_at is null or revoked_at >= granted_at)
);
create unique index uq_admin_active_school_role
 on tpmp_admin_poc.user_school_role_grants(membership_id,role_id,school_id)
 where revoked_at is null;
create index idx_admin_school_grants_school on tpmp_admin_poc.user_school_role_grants(school_id) where revoked_at is null;
-- Relationship explicitly binds supplier to a client school. Supplier identity is not duplicated.
create table tpmp_admin_poc.supplier_relationships (
 id uuid primary key default gen_random_uuid(),
 supplier_id uuid not null references tpmp_admin_poc.organizations(id),
 school_id uuid not null references tpmp_admin_poc.organizations(id),
 status text not null default 'active' check(status in ('active','inactive')),
 unique(id,supplier_id),
 unique(supplier_id,school_id)
);
create table tpmp_admin_poc.supplier_user_access (
 id uuid primary key default gen_random_uuid(),
 supplier_membership_id uuid not null references tpmp_admin_poc.organization_memberships(id),
 relationship_id uuid not null,
 supplier_id uuid not null,
 permission_code text not null references tpmp_admin_poc.permissions(code),
 granted_by uuid not null references auth.users(id),
 granted_at timestamptz not null default now(),
 revoked_at timestamptz,
 foreign key(relationship_id,supplier_id) references tpmp_admin_poc.supplier_relationships(id,supplier_id)
);
create unique index uq_admin_supplier_access_active
 on tpmp_admin_poc.supplier_user_access(supplier_membership_id,relationship_id,permission_code)
 where revoked_at is null;
-- The prototype deliberately provides NO client table access until authorization
-- functions, tenant integrity validation and protected audit/outbox are implemented.
alter table tpmp_admin_poc.organizations enable row level security;
alter table tpmp_admin_poc.user_profiles enable row level security;
alter table tpmp_admin_poc.organization_memberships enable row level security;
alter table tpmp_admin_poc.permissions enable row level security;
alter table tpmp_admin_poc.roles enable row level security;
alter table tpmp_admin_poc.role_permissions enable row level security;
alter table tpmp_admin_poc.user_school_role_grants enable row level security;
alter table tpmp_admin_poc.supplier_relationships enable row level security;
alter table tpmp_admin_poc.supplier_user_access enable row level security;
revoke all on all tables in schema tpmp_admin_poc from public, anon, authenticated;
-- Default-deny RLS, with no policies, until reviewed command boundary exists.
commit;
