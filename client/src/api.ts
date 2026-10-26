/**
 * Centralised API base URL for the SANTORI Music React client.
 * - In production builds: set VITE_API_URL in .env.production or Netlify/Render env vars.
 * - In local dev: falls back to http://127.0.0.1:8000 (FastAPI dev server).
 */
const envUrl = (import.meta as { env?: Record<string, string> }).env?.VITE_API_URL ?? '';
export const API_BASE = envUrl.trim() !== '' ? envUrl.trim() : 'http://127.0.0.1:8000';
