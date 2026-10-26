import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))  # allows: from app.main import app
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["database"] == "ok"

def test_search_and_trending_and_lyrics():
    # Test trending endpoint
    res_trending = client.get("/api/trending?language=hindi")
    assert res_trending.status_code == 200
    trending_songs = res_trending.json()
    assert isinstance(trending_songs, list)
    assert len(trending_songs) > 0
    assert "id" in trending_songs[0]
    assert "title" in trending_songs[0]
    assert "stream_url" in trending_songs[0]

    # Test search endpoint
    res_search = client.get("/api/search?q=Arijit&limit=3")
    assert res_search.status_code == 200
    search_results = res_search.json()
    assert isinstance(search_results, list)
    assert len(search_results) > 0
    first_id = search_results[0]["id"]

    # Test lyrics endpoint
    res_lyrics = client.get(f"/api/lyrics/{first_id}")
    assert res_lyrics.status_code == 200
    lyrics_data = res_lyrics.json()
    assert "lyrics" in lyrics_data
    if lyrics_data["lyrics"]:
        assert "<br>" not in lyrics_data["lyrics"]

def test_playlists_crud():
    # 1. List playlists
    res = client.get("/api/playlists")
    assert res.status_code == 200
    initial_count = len(res.json())

    # 2. Create playlist
    res2 = client.post("/api/playlists", json={"name": "Test Acoustic Folio", "description": "Testing description"})
    assert res2.status_code == 200
    created = res2.json()
    assert created["name"] == "Test Acoustic Folio"
    pid = created["id"]

    # 3. Add track to playlist
    track_payload = {
        "id": "test_s1",
        "title": "Acoustic Sample",
        "artist": "Folio Artist",
        "album": "Paper Sheets",
        "duration": 200,
        "image": "https://example.com/art.jpg",
        "stream_url": "https://example.com/audio.mp3"
    }
    res_track = client.post(f"/api/playlists/{pid}/tracks", json=track_payload)
    assert res_track.status_code == 200

    # 4. Delete playlist
    res_del = client.delete(f"/api/playlists/{pid}")
    assert res_del.status_code == 200

def test_likes_endpoint():
    track_payload = {
        "id": "like_test_123",
        "title": "Liked Track Test",
        "artist": "Test Artist",
        "album": "Desk Notes",
        "duration": 180,
        "image": "",
        "stream_url": ""
    }
    # Add like
    res = client.post("/api/likes", json=track_payload)
    assert res.status_code == 200

    # Verify in list
    res_list = client.get("/api/likes")
    assert res_list.status_code == 200
    ids = [item["id"] for item in res_list.json()]
    assert "like_test_123" in ids

    # Remove like
    res_del = client.delete("/api/likes/like_test_123")
    assert res_del.status_code == 200

def test_presets_endpoint():
    payload = {
        "name": "Custom Test Look",
        "shade": "charcoal",
        "ink": "pine",
        "grain": 0.45,
        "tilt": "1",
        "visualizer": "rings"
    }
    res = client.post("/api/presets", json=payload)
    assert res.status_code == 200

    res_get = client.get("/api/presets")
    names = [p["name"] for p in res_get.json()]
    assert "Custom Test Look" in names
