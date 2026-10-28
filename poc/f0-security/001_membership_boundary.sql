-- TPMP-F0-SEC-001: disposable Supabase development POC ONLY.
-- NOT a production migration. Run only after code review in an empty isolated project.
-- Assumes Supabase Auth provides auth.uid() from a VERIFIED request JWT.
-- Never expose direct SQL credentials to clients or trust a caller-supplied user_id.
begin;

create schema if not exists tpmp_poc;

create table tpmp_poc.organizations (
  id uuid primary key,
  name text not null check (length(trim(name)) > 0)
);

create table tpmp_poc.memberships (
  id uuid primary key,
  organization_id uuid not null references tpmp_poc.organizations(id),
  user_id uuid not null references auth.users(id),
  active boolean not null default true,
  unique (organization_id, user_id)
);

create table tpmp_poc.tenant_notes (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references tpmp_poc.organizations(id),
  title text not null check (length(trim(title)) > 0),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

-- RLS is enabled and forced even for table owners (not database superusers).
alter table tpmp_poc.organizations enable row level security;
alter table tpmp_poc.organizations force row level security;
alter table tpmp_poc.memberships enable row level security;
alter table tpmp_poc.memberships force row level security;
alter table tpmp_poc.tenant_notes enable row level security;
alter table tpmp_poc.tenant_notes force row level security;

revoke all on schema tpmp_poc from public;
revoke all on all tables in schema tpmp_poc from public, anon, authenticated;
grant usage on schema tpmp_poc to authenticated;
grant select on tpmp_poc.organizations to authenticated;
grant select on tpmp_poc.memberships to authenticated;
grant select, insert on tpmp_poc.tenant_notes to authenticated;

-- Users can see only their own membership records.
create policy rls_memberships_self_select on tpmp_poc.memberships
  for select to authenticated
  using (user_id = (select auth.uid()) and active = true);

-- Membership grants are provisioned by a separate trusted server operation,
-- never through a client INSERT/UPDATE/DELETE policy.
create policy rls_organizations_member_select on tpmp_poc.organizations
  for select to authenticated
  using (exists (
    select 1 from tpmp_poc.memberships m
    where m.organization_id = id and m.user_id = (select auth.uid()) and m.active
  ));

create policy rls_notes_member_select on tpmp_poc.tenant_notes
  for select to authenticated
  using (exists (
    select 1 from tpmp_poc.memberships m
    where m.organization_id = tenant_notes.organization_id
      and m.user_id = (select auth.uid()) and m.active
  ));

create policy rls_notes_member_insert on tpmp_poc.tenant_notes
  for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and exists (
      select 1 from tpmp_poc.memberships m
      where m.organization_id = tenant_notes.organization_id
        and m.user_id = (select auth.uid()) and m.active
    )
  );

-- Explicitly no UPDATE or DELETE grants/policies for clients.
-- For production, add module-specific permissions, organization scope versioning,
-- privileged provisioning commands, audit/outbox writes and composite tenant FKs.
commit;
