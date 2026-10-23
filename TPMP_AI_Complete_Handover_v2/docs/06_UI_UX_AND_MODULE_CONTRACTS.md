# UI/UX Design Principles and Modular Component Contract

## Product experience objectives
Modern, clear, professional enterprise SaaS; Gatekeeper-inspired functionality, not a copied visual design. Consistent navigation, readable density, actionable dashboards, visible ownership, current status, upcoming deadlines, missing evidence and approval history. Desktop-first responsive experience; mobile behavior designed deliberately rather than assumed.

## Main navigation — proposed information architecture
Dashboard; Organizations; Suppliers; Engagements; Personnel; Documents; Compliance; Contracts; Approvals/Tasks; Reports; Administration. Navigation grouping and exact page layouts are **proposed**, not separately approved.

## Reusable component strategy — agreed development method
Build page shells from stable reusable components with explicit props, contracts and tests. Examples: SupplierSummary, RelationshipStatus, ComplianceChecklist, EvidenceVersionPanel, PersonnelAssignmentCard, ContractTimeline, ApprovalHistory, ReviewQueue, ExpiryIndicator, AuditTrail, ScopedEntityPicker, PermissionGate. These are suggested component names, not a locked design.

## Rules for making changes
1. Identify the precise component and its public interface.
2. State requested change and what must remain unchanged.
3. Identify dependent screens and regression risks.
4. Change only the agreed component or feature contract.
5. Test visual and functional regressions in every consumer.
6. Suggest page-wide redesign separately; do not include it automatically.
7. Show a change log and request explicit approval for unrelated scope.

## Key screen behaviors
- Supplier overview distinguishes shared supplier identity from client-specific relationship and approvals.
- Compliance screen shows assigned requirements, evidence version, reviewer outcome, validity and reason for gaps.
- Personnel screen distinguishes supplier profile from client engagement/location assignment and operational authorization.
- Document screen shows version history, pending replacement, expiry and share grants.
- Contracts screen shows signed sources, amendments, effective terms and obligations.
- Review queue shows next actor, stage, due date, delegation/escalation and complete decision history.
- Reporting shows period, calculation version, freshness, filters and permissions.

## UI design system to specify before implementation
Typography scale, spacing, responsive breakpoints, color tokens, statuses, accessibility, table patterns, forms, empty/error/loading states, dialogs, confirmation patterns, reusable layout and component test conventions. Exact brand, fonts, colors and final layouts remain open.
