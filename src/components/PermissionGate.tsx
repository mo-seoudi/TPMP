import type { ReactNode } from 'react'

export interface PermissionGateProps {
  /** Result of a permission decision made elsewhere (server-side or RLS-backed). */
  allowed: boolean
  children: ReactNode
  fallback?: ReactNode
}

/**
 * UI affordance only. Hiding a control is NOT authorization (docs/05): every action is
 * enforced again in the database by RLS and D-22 command functions.
 */
export function PermissionGate({ allowed, children, fallback = null }: PermissionGateProps) {
  return <>{allowed ? children : fallback}</>
}
