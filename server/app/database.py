import datetime
import os
from sqlalchemy import (
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    create_engine,
)
from sqlalchemy.orm import declarative_base, relationship, sessionmaker

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "santori.db")
DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{DB_PATH}")

# Fix Render PostgreSQL URL format (postgres:// → postgresql://)
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# SQLite specific connect args
connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class LikedTrack(Base):
    __tablename__ = "liked_tracks"
    id = Column(Integer, primary_key=True, index=True)
    song_id = Column(String(100), unique=True, index=True, nullable=False)
    title = Column(String(255), nullable=False)
    artist = Column(String(255), nullable=False)
    album = Column(String(255), default="")
    duration = Column(Integer, default=0)
    image = Column(String(500), default="")
    stream_url = Column(Text, default="")
    created_at = Column(DateTime, default=lambda: datetime.datetime.now(datetime.timezone.utc))

class Playlist(Base):
    __tablename__ = "playlists"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    description = Column(String(255), default="")
    created_at = Column(DateTime, default=lambda: datetime.datetime.now(datetime.timezone.utc))
    tracks = relationship("PlaylistTrack", back_populates="playlist", cascade="all, delete-orphan")

class PlaylistTrack(Base):
    __tablename__ = "playlist_tracks"
    id = Column(Integer, primary_key=True, index=True)
    playlist_id = Column(Integer, ForeignKey("playlists.id", ondelete="CASCADE"), nullable=False)
    song_id = Column(String(100), nullable=False)
    title = Column(String(255), nullable=False)
    artist = Column(String(255), nullable=False)
    album = Column(String(255), default="")
    duration = Column(Integer, default=0)
    image = Column(String(500), default="")
    stream_url = Column(Text, default="")
    position = Column(Integer, default=0)
    playlist = relationship("Playlist", back_populates="tracks")

class SavedLook(Base):
    __tablename__ = "saved_looks"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    shade = Column(String(50), nullable=False)
    ink = Column(String(50), nullable=False)
    grain = Column(Float, default=0.35)
    tilt = Column(String(10), default="1")
    visualizer = Column(String(50), default="pencil")
    created_at = Column(DateTime, default=lambda: datetime.datetime.now(datetime.timezone.utc))

class ListeningHistory(Base):
    __tablename__ = "listening_history"
    id = Column(Integer, primary_key=True, index=True)
    song_id = Column(String(100), nullable=False)
    title = Column(String(255), nullable=False)
    artist = Column(String(255), nullable=False)
    album = Column(String(255), default="")
    image = Column(String(500), default="")
    played_at = Column(DateTime, default=datetime.datetime.utcnow)

def init_db():
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
