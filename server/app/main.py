import os
from typing import Any, Dict, List, Optional
from fastapi import Depends, FastAPI, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.orm import Session

from .database import (
    Base,
    LikedTrack,
    ListeningHistory,
    Playlist,
    PlaylistTrack,
    SavedLook,
    get_db,
    init_db,
)
from .saavn import get_song_lyrics, get_trending_songs, search_songs

# Initialize database tables on startup
init_db()

app = FastAPI(
    title="SANTORI Music API",
    description="High-fidelity music streaming backend with JioSaavn integration, playlists, and personalisation.",
    version="1.0.0",
)

production_frontend_origin = "https://aquamarine-taiyaki-1dd8e0.netlify.app"
frontend_origins = [
    origin.strip().rstrip("/")
    for origin in os.getenv("FRONTEND_ORIGINS", "").split(",")
    if origin.strip()
]
if not frontend_origins:
    frontend_origins = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:4173",
        "http://127.0.0.1:4173",
    ]
if production_frontend_origin not in frontend_origins:
    frontend_origins.append(production_frontend_origin)
if "*" in frontend_origins:
    raise ValueError("FRONTEND_ORIGINS must contain explicit origins, not '*'.")

app.add_middleware(
    CORSMiddleware,
    allow_origins=frontend_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Pydantic Schemas
class SongSchema(BaseModel):
    id: str
    title: str
    artist: str
    album: Optional[str] = ""
    duration: Optional[int] = 0
    image: Optional[str] = ""
    stream_url: Optional[str] = None
    media_preview_url: Optional[str] = None
    has_lyrics: Optional[bool] = False
    year: Optional[str] = ""
    language: Optional[str] = ""
    hue: Optional[int] = 210
    is_demo: Optional[bool] = False

class LikeRequest(BaseModel):
    id: str
    title: str
    artist: str
    album: Optional[str] = ""
    duration: Optional[int] = 0
    image: Optional[str] = ""
    stream_url: Optional[str] = ""

class PlaylistCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = ""

class PresetCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    shade: str
    ink: str
    grain: float = 0.35
    tilt: str = "1"
    visualizer: str = "pencil"

# Endpoints
@app.get("/api/health")
def health(db: Session = Depends(get_db)):
    db_status = "ok"
    try:
        db.execute(text("SELECT 1"))
    except Exception as e:
        db_status = f"unhealthy: {e}"
    return {
        "status": "ok",
        "app": "SANTORI Music Server",
        "version": "1.0.0",
        "database": db_status
    }

@app.get("/api/search", response_model=List[SongSchema])
def search_tracks(
    q: str = Query(..., min_length=1, description="Song, artist, or album query"),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=50)
):
    """Searches live tracks across Bollywood, Punjabi, Global songs with 320kbps streams."""
    songs = search_songs(q, page=page, limit=limit)
    return songs

@app.get("/api/trending", response_model=List[SongSchema])
def trending_tracks(language: str = Query("hindi", description="Language or chart category")):
    """Returns curated trending hits."""
    return get_trending_songs(language)

@app.get("/api/lyrics/{song_id}")
def song_lyrics(song_id: str):
    """Fetches lyrics if available."""
    lyrics = get_song_lyrics(song_id)
    if not lyrics:
        return {"lyrics": None, "message": "No lyrics found for this track."}
    return {"lyrics": lyrics}

# Liked Tracks
@app.get("/api/likes", response_model=List[SongSchema])
def list_likes(db: Session = Depends(get_db)):
    records = db.query(LikedTrack).order_by(LikedTrack.created_at.desc()).all()
    return [
        {
            "id": r.song_id,
            "title": r.title,
            "artist": r.artist,
            "album": r.album,
            "duration": r.duration,
            "image": r.image,
            "stream_url": r.stream_url,
            "hue": (abs(hash(r.song_id)) % 360),
            "is_demo": False,
        }
        for r in records
    ]

@app.post("/api/likes")
def add_like(item: LikeRequest, db: Session = Depends(get_db)):
    existing = db.query(LikedTrack).filter(LikedTrack.song_id == item.id).first()
    if existing:
        return {"status": "already_liked", "song_id": item.id}
    new_like = LikedTrack(
        song_id=item.id,
        title=item.title,
        artist=item.artist,
        album=item.album or "",
        duration=item.duration or 0,
        image=item.image or "",
        stream_url=item.stream_url or "",
    )
    db.add(new_like)
    db.commit()
    return {"status": "liked", "song_id": item.id}

@app.delete("/api/likes/{song_id}")
def remove_like(song_id: str, db: Session = Depends(get_db)):
    existing = db.query(LikedTrack).filter(LikedTrack.song_id == song_id).first()
    if existing:
        db.delete(existing)
        db.commit()
        return {"status": "unliked", "song_id": song_id}
    return {"status": "not_found", "song_id": song_id}

# Playlists
@app.get("/api/playlists")
def list_playlists(db: Session = Depends(get_db)):
    playlists = db.query(Playlist).order_by(Playlist.created_at.desc()).all()
    results = []
    for p in playlists:
        tracks = (
            db.query(PlaylistTrack)
            .filter(PlaylistTrack.playlist_id == p.id)
            .order_by(PlaylistTrack.position.asc())
            .all()
        )
        results.append({
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "created_at": p.created_at.isoformat() if p.created_at else None,
            "track_count": len(tracks),
            "tracks": [
                {
                    "id": t.song_id,
                    "title": t.title,
                    "artist": t.artist,
                    "album": t.album,
                    "duration": t.duration,
                    "image": t.image,
                    "stream_url": t.stream_url,
                }
                for t in tracks
            ]
        })
    return results

@app.post("/api/playlists")
def create_playlist(data: PlaylistCreate, db: Session = Depends(get_db)):
    p = Playlist(name=data.name, description=data.description or "")
    db.add(p)
    db.commit()
    db.refresh(p)
    return {"id": p.id, "name": p.name, "description": p.description, "track_count": 0, "tracks": []}

@app.delete("/api/playlists/{playlist_id}")
def delete_playlist(playlist_id: int, db: Session = Depends(get_db)):
    p = db.query(Playlist).filter(Playlist.id == playlist_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Playlist not found")
    db.delete(p)
    db.commit()
    return {"status": "deleted", "id": playlist_id}

@app.post("/api/playlists/{playlist_id}/tracks")
def add_track_to_playlist(playlist_id: int, track: LikeRequest, db: Session = Depends(get_db)):
    p = db.query(Playlist).filter(Playlist.id == playlist_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Playlist not found")
    
    count = db.query(PlaylistTrack).filter(PlaylistTrack.playlist_id == playlist_id).count()
    pt = PlaylistTrack(
        playlist_id=playlist_id,
        song_id=track.id,
        title=track.title,
        artist=track.artist,
        album=track.album or "",
        duration=track.duration or 0,
        image=track.image or "",
        stream_url=track.stream_url or "",
        position=count
    )
    db.add(pt)
    db.commit()
    return {"status": "added", "song_id": track.id}

@app.delete("/api/playlists/{playlist_id}/tracks/{song_id}")
def remove_track_from_playlist(playlist_id: int, song_id: str, db: Session = Depends(get_db)):
    pt = (
        db.query(PlaylistTrack)
        .filter(PlaylistTrack.playlist_id == playlist_id, PlaylistTrack.song_id == song_id)
        .first()
    )
    if pt:
        db.delete(pt)
        db.commit()
        return {"status": "removed"}
    return {"status": "not_found"}

# Presets / Saved Looks
@app.get("/api/presets")
def list_presets(db: Session = Depends(get_db)):
    presets = db.query(SavedLook).order_by(SavedLook.created_at.desc()).all()
    return [
        {
            "name": p.name,
            "shade": p.shade,
            "ink": p.ink,
            "grain": p.grain,
            "tilt": p.tilt,
            "visualizer": p.visualizer,
        }
        for p in presets
    ]

@app.post("/api/presets")
def save_preset(preset: PresetCreate, db: Session = Depends(get_db)):
    existing = db.query(SavedLook).filter(SavedLook.name == preset.name).first()
    if existing:
        existing.shade = preset.shade
        existing.ink = preset.ink
        existing.grain = preset.grain
        existing.tilt = preset.tilt
        existing.visualizer = preset.visualizer
    else:
        new_preset = SavedLook(
            name=preset.name,
            shade=preset.shade,
            ink=preset.ink,
            grain=preset.grain,
            tilt=preset.tilt,
            visualizer=preset.visualizer
        )
        db.add(new_preset)
    db.commit()
    return {"status": "saved", "name": preset.name}

@app.delete("/api/presets/{name}")
def delete_preset(name: str, db: Session = Depends(get_db)):
    p = db.query(SavedLook).filter(SavedLook.name == name).first()
    if p:
        db.delete(p)
        db.commit()
        return {"status": "deleted", "name": name}
    return {"status": "not_found"}
