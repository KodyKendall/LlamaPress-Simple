import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'happy-dom',
    globals: true,
    setupFiles: ['./spec/javascript/setup.js'],
    testTimeout: 10000,
    hookTimeout: 30000,
    include: ['spec/javascript/**/*.test.js'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['app/javascript/**/*.js']
    }
  }
})
