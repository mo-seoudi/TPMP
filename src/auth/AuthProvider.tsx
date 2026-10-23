import { useEffect, useMemo, useState, type ReactNode } from 'react'
import type { Session } from '@supabase/supabase-js'
import { getSupabase } from '../lib/supabase'
import { AuthContext, type AuthState, type AuthStatus } from './AuthContext'

/**
 * Identity comes from Supabase Auth. The sign-in method here (email link) is PROVISIONAL:
 * MFA and SSO policy are OPEN (docs/10 item 13). This provider holds no authorization logic.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const supabase = useMemo(() => getSupabase(), [])
  const [session, setSession] = useState<Session | null>(null)
  const [status, setStatus] = useState<AuthStatus>(supabase ? 'loading' : 'unconfigured')

  useEffect(() => {
    if (!supabase) return
    let active = true
    void supabase.auth.getSession().then(({ data }) => {
      if (!active) return
      setSession(data.session)
      setStatus(data.session ? 'signed-in' : 'signed-out')
    })
    const { data: sub } = supabase.auth.onAuthStateChange((_event, next) => {
      setSession(next)
      setStatus(next ? 'signed-in' : 'signed-out')
    })
    return () => {
      active = false
      sub.subscription.unsubscribe()
    }
  }, [supabase])

  const value = useMemo<AuthState>(
    () => ({
      status,
      session,
      signInWithEmail: async (email) => {
        if (!supabase) return { error: 'Authentication is not configured for this environment.' }
        const { error } = await supabase.auth.signInWithOtp({ email, options: { emailRedirectTo: window.location.origin } })
        return { error: error ? error.message : null }
      },
      signOut: async () => {
        if (supabase) await supabase.auth.signOut()
      },
    }),
    [status, session, supabase],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
