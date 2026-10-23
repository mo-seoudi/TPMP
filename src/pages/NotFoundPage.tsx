import { Link } from 'react-router-dom'

export function NotFoundPage() {
  return (
    <article className="card">
      <h1>Page not found</h1>
      <p>
        <Link to="/">Back to the dashboard</Link>
      </p>
    </article>
  )
}
