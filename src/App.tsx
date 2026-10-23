import { Route, Routes } from 'react-router-dom'
import { AppShell } from './components/AppShell'
import { ModulePlaceholder } from './components/ModulePlaceholder'
import { MODULES } from './modules/registry'
import { DashboardPage } from './pages/DashboardPage'
import { NotFoundPage } from './pages/NotFoundPage'
import { SignInPage } from './pages/SignInPage'
import { StatusPage } from './pages/StatusPage'

export function App() {
  return (
    <Routes>
      <Route element={<AppShell />}>
        <Route index element={<DashboardPage />} />
        {MODULES.map((m) => (
          <Route key={m.id} path={m.path.slice(1)} element={<ModulePlaceholder module={m} />} />
        ))}
        <Route path="sign-in" element={<SignInPage />} />
        <Route path="status" element={<StatusPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  )
}
