import { describe, expect, it } from 'vitest'
import { MODULES, findModule } from './registry'

describe('module registry', () => {
  it('has unique ids and unique paths', () => {
    expect(new Set(MODULES.map((m) => m.id)).size).toBe(MODULES.length)
    expect(new Set(MODULES.map((m) => m.path)).size).toBe(MODULES.length)
  })
  it('uses absolute paths and valid phases', () => {
    for (const m of MODULES) {
      expect(m.path.startsWith('/')).toBe(true)
      expect([1, 2, 3, 4, 5]).toContain(m.phase)
    }
  })
  it('references at least one decision and a spec for every module', () => {
    for (const m of MODULES) {
      expect(m.decisions.length).toBeGreaterThan(0)
      expect(m.spec.endsWith('.md')).toBe(true)
    }
  })
  it('does not use the ambiguous bare decision citation', () => {
    for (const m of MODULES) for (const d of m.decisions) expect(d).toMatch(/^(D|A)-\d{2}$/)
  })
  it('finds modules by id', () => {
    expect(findModule('documents')?.label).toBe('Documents')
    expect(findModule('nope')).toBeUndefined()
  })
})
