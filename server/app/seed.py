from .database import SessionLocal, LikedTrack, Playlist, PlaylistTrack, SavedLook, init_db

def seed_demo_data():
    init_db()
    db = SessionLocal()
    try:
        # Check if already seeded
        if db.query(Playlist).count() == 0:
            p1 = Playlist(name="Lofi & Study Folio", description="Relaxing acoustic and tape tones")
            p2 = Playlist(name="Midnight Deep Glow", description="Atmospheric synth waves and ambient textures")
            db.add_all([p1, p2])
            db.commit()
            db.refresh(p1)
            db.refresh(p2)

            tracks = [
                ("1", "Paper Horizon (Demo)", "Folio Ensemble", "Acoustic Sheets", 195, "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80", ""),
                ("2", "Graphite Echoes (Demo)", "Desk Quartet", "Ruled Notebook Vol. 1", 210, "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80", ""),
                ("3", "Ocean Drift (Demo)", "SANTORI Waves", "Midnight Tapes", 240, "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=80", ""),
            ]
            for i, (sid, title, artist, album, dur, img, url) in enumerate(tracks):
                pt = PlaylistTrack(
                    playlist_id=p1.id,
                    song_id=sid,
                    title=title,
                    artist=artist,
                    album=album,
                    duration=dur,
                    image=img,
                    stream_url=url,
                    position=i
                )
                db.add(pt)
            db.commit()

        # Seed presets if empty
        if db.query(SavedLook).count() == 0:
            presets = [
                SavedLook(name="Study Session", shade="stone", ink="blue-black", grain=0.35, tilt="1", visualizer="pencil"),
                SavedLook(name="Night Glow", shade="charcoal", ink="blue-black", grain=0.25, tilt="1", visualizer="rings"),
                SavedLook(name="Ocean Drift", shade="ocean-dark", ink="neon-cyan", grain=0.20, tilt="0", visualizer="ink"),
                SavedLook(name="Dark Violet", shade="dark-purple", ink="electric-violet", grain=0.15, tilt="1", visualizer="pencil"),
            ]
            db.add_all(presets)
            db.commit()
        print("Database seeded successfully!")
    finally:
        db.close()

if __name__ == "__main__":
    seed_demo_data()
