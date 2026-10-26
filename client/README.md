# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some Oxlint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Oxc](https://oxc.rs)
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/)

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the Oxlint configuration

If you are developing a production application, we recommend enabling type-aware lint rules by installing `oxlint-tsgolint` and editing `.oxlintrc.json`:

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["react", "typescript", "oxc"],
  "options": {
    "typeAware": true
  },
  "rules": {
    "react/rules-of-hooks": "error",
    "react/only-export-components": ["warn", { "allowConstantExport": true }]
  }
}
```

See the [Oxlint rules documentation](https://oxc.rs/docs/guide/usage/linter/rules) for the full list of rules and categories.

## Production deployment

This client is a static React single-page application built with Vite. Netlify is a suitable hosting option:

1. Import this repository into Netlify.
2. Set the **Base directory** to `client`, the **Build command** to `npm run build`, and the **Publish directory** to `dist`.
3. Set the build environment variable `VITE_API_URL` to `https://santori-music.onrender.com`.
4. The backend allows the production site origin `https://aquamarine-taiyaki-1dd8e0.netlify.app` by default. In the Render backend service, set `FRONTEND_ORIGINS` to include any additional Netlify preview or custom-domain origins, separated by commas, then redeploy the backend.
5. Deploy the frontend, then open the deployed site and verify that its home, search, and library views can reach the backend.

`VITE_API_URL` is the backend origin; the client appends `/api` to API paths. The committed production environment file already supplies the Render URL, though the hosting environment variable can override it.

The client uses lightweight URL-backed navigation for Home (`/`), Search (`/search`), Library (`/library`), and Now Playing (`/player`). The shared audio provider remains mounted across these views, so playback continues when navigating. Configure the host to serve `index.html` for unmatched paths (the root `netlify.toml` already includes the required `/* /index.html 200` redirect).

For local development, run the backend at `http://127.0.0.1:8000` and start Vite with `npm run dev`; the API URL defaults to that local backend. The backend allows local Vite origins by default. Configure its `FRONTEND_ORIGINS` environment variable with explicit production origins; wildcard origins are rejected.
