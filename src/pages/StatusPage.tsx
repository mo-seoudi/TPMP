import { isSupabaseConfigured } from '../lib/env'
import { MODULES } from '../modules/registry'

/** Plain statement of what exists. Keep in step with TPMP_AI_Complete_Handover_v2/docs/14. */
export function StatusPage() {
  return (
    <article className="card">
      <p className="eyebrow">Build status</p>
      <h1>What exists</h1>
      <ul className="plain">
        <li>Application shell, navigation and sign-in form: built, awaiting CI verification.</li>
        <li>Database foundation (audit ledger, outbox): migrations and SQL tests exist; not deployed to any Supabase project.</li>
        <li>
          Supabase configured in this environment: <strong>{isSupabaseConfigured() ? 'yes' : 'no'}</strong>
        </li>
        <li>Business modules: {MODULES.length} planned, none built.</li>
        <li>Deployment: preview only. No production environment.</li>
      </ul>
    </article>
  )
}
