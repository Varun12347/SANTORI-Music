import base64
import json
import re
import urllib.parse
import urllib.request
from typing import Any, Dict, List, Optional
from pyDes import des, ECB, PAD_PKCS5

DES_KEY = b"38346591"

def decrypt_media_url(enc_url: str) -> Optional[str]:
    """Decrypts JioSaavn's encrypted_media_url to direct 320kbps stream URL."""
    if not enc_url:
        return None
    try:
        cipher = des(DES_KEY, ECB, b"\0\0\0\0\0\0\0\0", pad=None, padmode=PAD_PKCS5)
        raw_bytes = base64.b64decode(enc_url.strip())
        decrypted = cipher.decrypt(raw_bytes, padmode=PAD_PKCS5).decode("utf-8")
        # Upgrade to 320kbps high bitrate
        url = decrypted.replace("_96.mp4", "_320.mp4").replace("_160.mp4", "_320.mp4")
        return url
    except Exception as e:
        print(f"Decryption error: {e}")
        return None

def clean_html(text: str) -> str:
    """Removes HTML entities and tags from titles/lyrics while preserving line breaks."""
    if not text:
        return ""
    text = re.sub(r"<br\s*/?>", "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"&quot;", '"', text)
    text = re.sub(r"&amp;", '&', text)
    text = re.sub(r"&#039;", "'", text)
    text = re.sub(r"&lt;", '<', text)
    text = re.sub(r"&gt;", '>', text)
    text = re.sub(r"&nbsp;", ' ', text)
    text = re.sub(r"<[^>]+>", '', text)
    return text.strip()

def format_image_url(img_url: Optional[str]) -> str:
    if not img_url:
        return "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80"
    return img_url.replace("50x50.jpg", "500x500.jpg").replace("150x150.jpg", "500x500.jpg")

def search_songs(query: str, page: int = 1, limit: int = 20) -> List[Dict[str, Any]]:
    """Searches songs on JioSaavn and returns clean parsed objects."""
    encoded_q = urllib.parse.quote(query)
    url = (
        f"https://www.jiosaavn.com/api.php?__call=search.getResults"
        f"&q={encoded_q}&_format=json&_marker=0&api_version=4&ctx=web6dot0"
        f"&n={limit}&p={page}"
    )
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
    
    try:
        with urllib.request.urlopen(req, timeout=8) as resp:
            data = json.loads(resp.read().decode("utf-8", errors="ignore"))
            results = data.get("results", [])
            songs: List[Dict[str, Any]] = []
            
            for item in results:
                more_info = item.get("more_info", {})
                enc_url = more_info.get("encrypted_media_url")
                media_url = decrypt_media_url(enc_url)
                
                # Derive hue from song ID hash for UI theming and pentatonic fallback
                song_id = str(item.get("id", ""))
                hue = (abs(hash(song_id)) % 360) if song_id else 210
                
                # Format primary artists
                primary_artists = item.get("primary_artists") or ""
                if not primary_artists and "artistMap" in more_info:
                    artists_list = more_info.get("artistMap", {}).get("primary_artists", [])
                    primary_artists = ", ".join([a.get("name", "") for a in artists_list if a.get("name")])
                
                duration = 0
                try:
                    duration = int(more_info.get("duration", 0))
                except (ValueError, TypeError):
                    duration = 180

                song = {
                    "id": song_id,
                    "title": clean_html(item.get("title", "")),
                    "artist": clean_html(primary_artists or item.get("singers", "Various Artists")),
                    "album": clean_html(item.get("album", "") or more_info.get("album", "")),
                    "duration": duration,
                    "image": format_image_url(item.get("image")),
                    "stream_url": media_url,
                    "media_preview_url": more_info.get("media_preview_url"),
                    "has_lyrics": more_info.get("has_lyrics") == "true",
                    "year": item.get("year", ""),
                    "language": item.get("language", ""),
                    "hue": hue,
                    "is_demo": False
                }
                songs.append(song)
            return songs
    except Exception as e:
        print(f"Error searching JioSaavn: {e}")
        return []

def get_trending_songs(language: str = "hindi") -> List[Dict[str, Any]]:
    """Gets top trending songs for the given language / charts."""
    # Queries curated popular sets
    query = "Top Trending 2024" if language == "all" else f"Top {language.title()} Hits"
    songs = search_songs(query, page=1, limit=16)
    if not songs:
        # Fallback queries
        songs = search_songs("Arijit Singh", page=1, limit=16)
    return songs

def get_song_lyrics(song_id: str) -> Optional[str]:
    """Fetches song lyrics from JioSaavn by song ID."""
    url = f"https://www.jiosaavn.com/api.php?__call=lyrics.getLyrics&lyrics_id={song_id}&_format=json&_marker=0&api_version=4&ctx=web6dot0"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=6) as resp:
            data = json.loads(resp.read().decode("utf-8", errors="ignore"))
            lyrics = data.get("lyrics", "")
            return clean_html(lyrics)
    except Exception as e:
        print(f"Error getting lyrics: {e}")
        return None
