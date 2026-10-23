import { describe, expect, it } from 'vitest'
import { isSupabaseConfigured, readPublicEnv } from './env'

describe('public env', () => {
  it('treats blank values as missing', () => {
    const env = readPublicEnv({ VITE_SUPABASE_URL: '  ', VITE_SUPABASE_ANON_KEY: '' } as ImportMetaEnv)
    expect(env.supabaseUrl).toBeUndefined()
    expect(isSupabaseConfigured(env)).toBe(false)
  })
  it('requires both values', () => {
    expect(isSupabaseConfigured({ supabaseUrl: 'https://x.supabase.co', supabaseAnonKey: undefined })).toBe(false)
    expect(isSupabaseConfigured({ supabaseUrl: 'https://x.supabase.co', supabaseAnonKey: 'anon' })).toBe(true)
  })
  it('trims whitespace', () => {
    const env = readPublicEnv({ VITE_SUPABASE_URL: ' https://x.supabase.co ', VITE_SUPABASE_ANON_KEY: ' k ' } as ImportMetaEnv)
    expect(env.supabaseUrl).toBe('https://x.supabase.co')
    expect(env.supabaseAnonKey).toBe('k')
  })
})
