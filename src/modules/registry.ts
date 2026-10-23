/**
 * Module registry. Navigation follows the PROPOSED information architecture in docs/06
 * (not separately approved). Phases follow docs/09 as revised by docs/16.
 * No fields, statuses or permissions are defined here: those are OPEN (docs/10).
 */
export type Phase = 1 | 2 | 3 | 4 | 5

export interface ModuleEntry {
  readonly id: string
  readonly label: string
  readonly path: string
  readonly phase: Phase
  /** Decision references from docs/02 and docs/16. */
  readonly decisions: readonly string[]
  /** Specification file relative to TPMP_AI_Complete_Handover_v2/docs. */
  readonly spec: string
}

export const MODULES: readonly ModuleEntry[] = [
  { id: 'organizations', label: 'Organizations', path: '/organizations', phase: 1, decisions: ['D-01', 'D-15', 'D-23'], spec: 'modules/organizations_and_suppliers.md' },
  { id: 'suppliers', label: 'Suppliers', path: '/suppliers', phase: 2, decisions: ['D-02', 'D-03', 'A-05'], spec: 'modules/organizations_and_suppliers.md' },
  { id: 'engagements', label: 'Engagements', path: '/engagements', phase: 2, decisions: ['D-05'], spec: 'modules/organizations_and_suppliers.md' },
  { id: 'documents', label: 'Documents', path: '/documents', phase: 3, decisions: ['D-07', 'D-08'], spec: 'modules/documents_and_compliance.md' },
  { id: 'compliance', label: 'Compliance', path: '/compliance', phase: 3, decisions: ['D-05', 'D-06', 'A-05'], spec: 'modules/documents_and_compliance.md' },
  { id: 'approvals', label: 'Approvals', path: '/approvals', phase: 3, decisions: ['D-13', 'A-03', 'D-24'], spec: 'modules/workflows_and_approvals.md' },
  { id: 'personnel', label: 'Personnel', path: '/personnel', phase: 4, decisions: ['D-09', 'D-10', 'A-05'], spec: 'modules/personnel.md' },
  { id: 'contracts', label: 'Contracts', path: '/contracts', phase: 5, decisions: ['D-11', 'D-12', 'A-05'], spec: 'modules/contracts.md' },
  { id: 'reports', label: 'Reports', path: '/reports', phase: 5, decisions: ['D-17', 'A-04'], spec: 'modules/reporting.md' },
  { id: 'administration', label: 'Administration', path: '/administration', phase: 1, decisions: ['D-15', 'D-16'], spec: 'modules/users_and_security.md' },
] as const

export function findModule(id: string): ModuleEntry | undefined {
  return MODULES.find((m) => m.id === id)
}
