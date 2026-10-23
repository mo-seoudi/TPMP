import { createContext } from 'react'
import type { Session } from '@supabase/supabase-js'

export type AuthStatus = 'unconfigured' | 'loading' | 'signed-out' | 'signed-in'

export interface AuthState {
  status: AuthStatus
  session: Session | null
  signInWithEmail: (email: string) => Promise<{ error: string | null }>
  signOut: () => Promise<void>
}

export const AuthContext = createContext<AuthState | null>(null)
