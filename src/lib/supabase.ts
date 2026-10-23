import { createClient, type SupabaseClient } from '@supabase/supabase-js'
import { readPublicEnv } from './env'

let client: SupabaseClient | null | undefined

/**
 * Returns the browser Supabase client, or null when the public env vars are absent
 * (e.g. a fresh Vercel preview). The app must keep rendering in that case.
 * Authorization is never decided here: RLS and D-22 command functions decide (docs/16).
 */
export function getSupabase(): SupabaseClient | null {
  if (client !== undefined) return client
  const { supabaseUrl, supabaseAnonKey } = readPublicEnv()
  client = supabaseUrl && supabaseAnonKey ? createClient(supabaseUrl, supabaseAnonKey) : null
  return client
}
