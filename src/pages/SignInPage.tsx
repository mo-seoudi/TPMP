import { useState, type FormEvent } from 'react'
import { useAuth } from '../auth/useAuth'

export function SignInPage() {
  const { status, signInWithEmail } = useAuth()
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState<{ kind: 'ok' | 'error'; text: string } | null>(null)
  const [busy, setBusy] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setBusy(true)
    const { error } = await signInWithEmail(email.trim())
    setBusy(false)
    setMessage(error ? { kind: 'error', text: error } : { kind: 'ok', text: 'Check your email for the sign-in link.' })
  }

  if (status === 'unconfigured') {
    return (
      <article className="card">
        <h1>Sign in</h1>
        <p>Authentication is not configured for this environment.</p>
      </article>
    )
  }
  if (status === 'signed-in') {
    return (
      <article className="card">
        <h1>Sign in</h1>
        <p>You are signed in.</p>
      </article>
    )
  }
  return (
    <article className="card">
      <h1>Sign in</h1>
      <form onSubmit={(e) => void onSubmit(e)} className="form">
        <label htmlFor="email">Email address</label>
        <input id="email" type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
        <button type="submit" className="btn" disabled={busy || email.trim().length === 0}>
          Email me a sign-in link
        </button>
        {message && (
          <p role={message.kind === 'error' ? 'alert' : 'status'} className={`msg msg--${message.kind}`}>
            {message.text}
          </p>
        )}
      </form>
    </article>
  )
}
