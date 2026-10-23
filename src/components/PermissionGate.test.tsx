import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { PermissionGate } from './PermissionGate'

describe('PermissionGate', () => {
  it('renders children when allowed', () => {
    render(<PermissionGate allowed>secret</PermissionGate>)
    expect(screen.getByText('secret')).toBeInTheDocument()
  })
  it('renders the fallback when not allowed', () => {
    render(
      <PermissionGate allowed={false} fallback={<span>no access</span>}>
        secret
      </PermissionGate>,
    )
    expect(screen.queryByText('secret')).not.toBeInTheDocument()
    expect(screen.getByText('no access')).toBeInTheDocument()
  })
  it('renders nothing by default when not allowed', () => {
    const { container } = render(<PermissionGate allowed={false}>secret</PermissionGate>)
    expect(container).toBeEmptyDOMElement()
  })
})
