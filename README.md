# FOLIO & SANTORI — Paper-Style & Claymorphic Music Streaming App

A tactile music streaming web application built with **React + TypeScript + Vite + Tailwind CSS** on the frontend, and **Python FastAPI + SQLite/PostgreSQL** on the backend, featuring direct **JioSaavn 320kbps audio streaming** and a **Web Audio API synthesizer fallback**.

---

## 🎨 Themes & Design System

The application implements tactile physical desk effects and custom claymorphic depth:

1. **Gray Paper Themes**:
   - **Stone (Default)**: `#b4b2ad` / `#dedcd7` / `#d2d0ca`
   - **Fog**: `#c3c4c4` / `#e8e8e6` / `#dcdddb`
   - **Slate**: `#9fa1a3` / `#d3d4d4` / `#c6c7c8`
   - **Charcoal (Dark Paper)**: `#17181b` / `#2a2c31` / `#34363c`
2. **Claymorphic Themes (Custom)**:
   - **Dark Purple**: Deep violet neon with soft 3D claymorphic depth (`#110d1f` / `#1c1533` / `#261c47`)
   - **Ocean Dark**: Deep teal aquatic glow (`#0a151d` / `#10212d` / `#162d3e`)
3. **Paper Effects**:
   - Fullscreen **SVG `feTurbulence` grain filter** with user opacity slider (0–0.7).
   - **Polaroid cover art** with taped top strip and alternating subtle tilts (`-1.4deg` / `+1.1deg`, straightening on hover).
   - **Ruled notebook queue** with horizontal lines, red margin line, and numbered sequence.
   - **Rubber stamp "LIKED" mark** on saved tracks.
   - **Perforated player bar** with dashed tear line at the top.
   - **Tactile buttons**: solid ink fill with hard bottom shadow, pressing down 2px on click.

---

## 🎵 Audio Engine & Features

- **JioSaavn Core Integration**: Real-time track search across Bollywood, Punjabi, and Global songs with direct DES-decrypted 320kbps audio streams.
- **Web Audio API Synthesizer**: Minor-pentatonic tone generation derived from track hue when playing offline or in demo mode.
- **Interactive Visualizer Canvas**: Real-time rendering driven by `AnalyserNode` with 3 styles:
  - *Pencil* (vertical graphite strokes with slight jitter)
  - *Ink wave* (continuous ink line)
  - *Rings* (concentric wobbly rings)
- **Sleep Timer**: 15m / 30m / 60m countdown with live badge and automatic pause.
- **Auto Shade by Time of Day**: Device clock-based switching (Stone < 17:00, Slate 17:00–21:00, Charcoal > 21:00).
- **Desk Settings Drawer**: Customize shade, ink, grain, tilts, presets, and shareable base64 look codes with whitelist validation.

---

## 🚀 Getting Started

### 1. Prerequisites
- **Node.js** >= 18
- **Python** >= 3.10

### 2. Backend Setup (FastAPI)
```bash
# In project root:
python -m pip install -r server/requirements.txt
python -m server.app.seed
python -m uvicorn server.app.main:app --host 127.0.0.1 --port 8000
```
API Documentation will be live at: `http://127.0.0.1:8000/docs`

### 3. Frontend Setup (React + Vite)
```bash
cd client
npm install
npm run dev -- --host 127.0.0.1 --port 5173
```
Open your browser at: `http://127.0.0.1:5173/`

---

## 🧪 Automated Tests

### Backend Tests (pytest)
```bash
python -m pytest server/tests/test_api.py -v
```
Verifies health check, playlist CRUD, likes persistence, and desk preset endpoints.

### Frontend Tests (Vitest)
```bash
cd client
npx vitest run
```
Verifies look-code base64 validation against whitelists, grain bounds, corrupted input rejection, and auto-shade mapping.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Space` | Play / Pause |
| `Alt + Right` | Next track in queue |
| `Alt + Left` | Previous track (or restart if >3s in) |
| `Esc` | Close Desk Settings drawer |
