import type { ReactNode } from 'react'

export interface BannerProps {
  tone: 'info' | 'warning'
  children: ReactNode
}

export function Banner({ tone, children }: BannerProps) {
  return (
    <div className={`banner banner--${tone}`} role="status">
      {children}
    </div>
  )
}
