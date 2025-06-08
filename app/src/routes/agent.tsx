import { createFileRoute } from '@tanstack/react-router'
import { runClaude } from '@/lib/claude'

export const Route = createFileRoute('/agent')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div className="p-4">
      Hello "/agent"!{' '}
      <button onClick={async () => await runClaude()}>Agent things</button>
    </div>
  )
}
