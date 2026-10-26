/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        serif: ["Fraunces", "serif"],
        sans: ["Karla", "sans-serif"],
      },
      colors: {
        desk: "var(--color-desk)",
        paper: "var(--color-paper)",
        paper2: "var(--color-paper2)",
        ink: "var(--color-ink)",
        text: "var(--color-text)",
        muted: "var(--color-muted)",
        rule: "var(--color-rule)",
        stamp: "var(--color-stamp)",
      },
      boxShadow: {
        'paper': '0 4px 12px -2px rgba(0, 0, 0, 0.12), 0 2px 4px -1px rgba(0, 0, 0, 0.08), 0 1px 0 rgba(255, 255, 255, 0.2) inset',
        'paper-dark': '0 8px 24px -4px rgba(0, 0, 0, 0.45), 0 3px 6px -2px rgba(0, 0, 0, 0.3), 0 1px 0 rgba(255, 255, 255, 0.06) inset',
        'clay': 'inset 2px 2px 5px rgba(255, 255, 255, 0.12), inset -2px -2px 5px rgba(0, 0, 0, 0.35), 0 8px 16px rgba(0, 0, 0, 0.25)',
        'tactile': '0 2px 0 0 var(--color-ink-shadow, #1a243b)',
        'tactile-pressed': '0 0 0 0 transparent',
      },
      borderRadius: {
        'sheet': '3px',
      }
    },
  },
  plugins: [],
}
