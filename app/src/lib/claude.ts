import { spawn } from 'node:child_process'
import { createServerFn } from '@tanstack/react-start'

export const runClaude = createServerFn({
  method: 'GET',
}).handler(async () => {
  try {
    return new Promise((resolve) => {
      const child = spawn(
        'claude',
        [
          '-p',
          'Generate a hello world server function in the lib folder',
          '--output-format',
          'json',
          '--dangerously-skip-permissions',
        ],
        {
          stdio: ['pipe', 'pipe', 'pipe'], // Explicitly set stdio
        },
      )

      let output = ''
      let errorOutput = ''

      child.stdout.on('data', (data) => {
        output += data.toString()
        console.log('[stdout]', data.toString())
      })

      child.stderr.on('data', (data) => {
        errorOutput += data.toString()
        console.log('[stderr]', data.toString())
      })

      child.on('close', (code) => {
        resolve({
          code,
          output: JSON.stringify(output),
          errorOutput,
        })
      })

      // Close stdin immediately to prevent hanging on input
      child.stdin.end()

      console.log('Starting claude process...')
      console.log('PID:', child.pid)
    })
  } catch (e) {
    console.error(e)
    throw e
  }
})
