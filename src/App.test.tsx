import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'
import { App } from './App'
import { AuthProvider } from './auth/AuthProvider'
import { MODULES } from './modules/registry'

function renderAt(path: string) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <AuthProvider>
        <App />
      </AuthProvider>
    </MemoryRouter>,
  )
}

describe('application shell', () => {
  it('shows the unconfigured-auth banner when Supabase env is absent', () => {
    renderAt('/')
    expect(screen.getByRole('status')).toHaveTextContent(/not configured/i)
  })
  it('lists every registered module in the primary navigation', () => {
    renderAt('/')
    const nav = screen.getByRole('navigation', { name: 'Primary' })
    for (const m of MODULES) expect(nav).toHaveTextContent(m.label)
  })
  it('navigates to an honest module placeholder', async () => {
    renderAt('/')
    await userEvent.click(screen.getByRole('link', { name: 'Suppliers' }))
    expect(screen.getByRole('heading', { name: 'Suppliers' })).toBeInTheDocument()
    expect(screen.getByText(/not built yet/i)).toBeInTheDocument()
    expect(screen.getByText('D-02, D-03, A-05')).toBeInTheDocument()
  })
  it('reports that nothing is configured on the status page', () => {
    renderAt('/status')
    expect(screen.getByText('no')).toBeInTheDocument()
  })
  it('shows a not-found page for unknown routes', () => {
    renderAt('/does-not-exist')
    expect(screen.getByRole('heading', { name: 'Page not found' })).toBeInTheDocument()
  })
  it('explains that sign-in is unavailable when unconfigured', () => {
    renderAt('/sign-in')
    expect(screen.getByText(/not configured for this environment/i)).toBeInTheDocument()
  })
})
