import type { ModuleEntry } from '../modules/registry'

export interface ModulePlaceholderProps {
  module: ModuleEntry
}

/** Honest placeholder: states what is approved to exist and what is not built or specified yet. */
export function ModulePlaceholder({ module }: ModulePlaceholderProps) {
  return (
    <article className="card" aria-labelledby={`h-${module.id}`}>
      <p className="eyebrow">Planned for phase {module.phase}</p>
      <h1 id={`h-${module.id}`}>{module.label}</h1>
      <p>
        This module is not built yet. Its detailed functional specification is not approved, so no fields,
        statuses or screens exist here.
      </p>
      <dl className="meta">
        <dt>Decisions</dt>
        <dd>{module.decisions.join(', ')}</dd>
        <dt>Specification</dt>
        <dd>
          <code>docs/{module.spec}</code>
        </dd>
      </dl>
    </article>
  )
}
