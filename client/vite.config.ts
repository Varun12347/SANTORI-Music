import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
// VITE_API_URL is injected at build time from .env.production or the host environment.
export default defineConfig({
  plugins: [react()],
  envPrefix: 'VITE_',
})
