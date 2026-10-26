/**
 * Centralised API base URL for the SANTORI Music React client.
 * VITE_API_URL is the backend origin; API paths add /api themselves.
 */
const configuredUrl = import.meta.env.VITE_API_URL?.trim();
const defaultUrl = import.meta.env.PROD
  ? 'https://santori-music.onrender.com'
  : 'http://127.0.0.1:8000';

export const API_BASE = (configuredUrl || defaultUrl)
  .replace(/\/+$/, '')
  .replace(/\/api$/i, '');
