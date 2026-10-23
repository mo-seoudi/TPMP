/** Public (browser-safe) configuration only. Privileged keys must never be read here. */
export interface PublicEnv {
  supabaseUrl: string | undefined
  supabaseAnonKey: string | undefined
}

export function readPublicEnv(env: ImportMetaEnv = import.meta.env): PublicEnv {
  const clean = (v: string | undefined) => (v && v.trim().length > 0 ? v.trim() : undefined)
  return { supabaseUrl: clean(env.VITE_SUPABASE_URL), supabaseAnonKey: clean(env.VITE_SUPABASE_ANON_KEY) }
}

export function isSupabaseConfigured(env: PublicEnv = readPublicEnv()): boolean {
  return Boolean(env.supabaseUrl && env.supabaseAnonKey)
}
