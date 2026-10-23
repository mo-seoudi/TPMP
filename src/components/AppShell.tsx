import { NavLink, Outlet } from 'react-router-dom'
import { MODULES } from '../modules/registry'
import { useAuth } from '../auth/useAuth'
import { Banner } from './Banner'

export function AppShell() {
  const { status, session, signOut } = useAuth()
  return (
    <div className="shell">
      <a className="skip" href="#main">
        Skip to content
      </a>
      <header className="topbar">
        <NavLink to="/" className="brand">
          TPMP
        </NavLink>
        <div className="who">
          {status === 'signed-in' && session?.user.email ? (
            <>
              <span>{session.user.email}</span>
              <button type="button" className="btn btn--ghost" onClick={() => void signOut()}>
                Sign out
              </button>
            </>
          ) : (
            <NavLink to="/sign-in">Sign in</NavLink>
          )}
        </div>
      </header>
      <nav className="nav" aria-label="Primary">
        <ul>
          <li>
            <NavLink to="/" end>
              Dashboard
            </NavLink>
          </li>
          {MODULES.map((m) => (
            <li key={m.id}>
              <NavLink to={m.path}>{m.label}</NavLink>
            </li>
          ))}
          <li>
            <NavLink to="/status">Build status</NavLink>
          </li>
        </ul>
      </nav>
      <main id="main" className="main">
        {status === 'unconfigured' && (
          <Banner tone="warning">
            Authentication is not configured in this environment. The app is showing its structure only.
          </Banner>
        )}
        <Outlet />
      </main>
    </div>
  )
}
