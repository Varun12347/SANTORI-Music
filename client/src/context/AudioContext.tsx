import React, { createContext, useContext, useEffect, useRef, useState } from 'react';
import { globalAudioEngine } from '../audio/synthEngine';
import { API_BASE } from '../api';

export interface Track {
  id: string;
  title: string;
  artist: string;
  album?: string;
  duration?: number;
  image?: string;
  stream_url?: string;
  media_preview_url?: string;
  has_lyrics?: boolean;
  year?: string;
  hue?: number;
  is_demo?: boolean;
}

export type RepeatMode = 'off' | 'all' | 'one';

interface AudioContextType {
  currentTrack: Track | null;
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  volume: number;
  shuffle: boolean;
  repeat: RepeatMode;
  queue: Track[];
  likedIds: string[];
  likedTracks: Track[];
  playTrack: (track: Track, newQueue?: Track[]) => void;
  togglePlay: () => void;
  nextTrack: () => void;
  prevTrack: () => void;
  seek: (time: number) => void;
  setVolume: (vol: number) => void;
  toggleShuffle: () => void;
  toggleRepeat: () => void;
  toggleLike: (track: Track) => void;
  addToQueue: (track: Track) => void;
  removeFromQueue: (index: number) => void;
  isLiked: (id: string) => boolean;
}

const AudioContext = createContext<AudioContextType | null>(null);

const DEMO_QUEUE: Track[] = [
  {
    id: 'demo-1',
    title: 'Paper Horizon',
    artist: 'Folio Ensemble',
    album: 'Acoustic Sheets',
    duration: 195,
    image: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80',
    hue: 215,
    is_demo: true,
  },
  {
    id: 'demo-2',
    title: 'Graphite Echoes',
    artist: 'Desk Quartet',
    album: 'Ruled Notebook Vol. 1',
    duration: 210,
    image: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80',
    hue: 140,
    is_demo: true,
  },
  {
    id: 'demo-3',
    title: 'Ocean Midnight Tapes',
    artist: 'SANTORI Waves',
    album: 'Midnight Drifts',
    duration: 240,
    image: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=80',
    hue: 195,
    is_demo: true,
  },
];

export const AudioProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentTrack, setCurrentTrack] = useState<Track | null>(DEMO_QUEUE[0]);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [currentTime, setCurrentTime] = useState<number>(0);
  const [duration, setDuration] = useState<number>(DEMO_QUEUE[0].duration || 180);
  const [volume, setVolumeState] = useState<number>(0.85);
  const [shuffle, setShuffle] = useState<boolean>(false);
  const [repeat, setRepeat] = useState<RepeatMode>('off');
  const [queue, setQueue] = useState<Track[]>(DEMO_QUEUE);
  const [likedIds, setLikedIds] = useState<string[]>(() => {
    try {
      const saved = localStorage.getItem('folio_likes');
      if (saved) return JSON.parse(saved);
    } catch {
      // Ignored
    }
    return ['demo-1'];
  });
  const [likedTracks, setLikedTracks] = useState<Track[]>([DEMO_QUEUE[0]]);

  const synthTimerRef = useRef<number | null>(null);

  // Sync volume with audio engine
  const handleSetVolume = (vol: number) => {
    setVolumeState(vol);
    globalAudioEngine.setVolume(vol);
  };

  // HTML5 audio event bindings
  useEffect(() => {
    const audioEl = globalAudioEngine.getAudioElement();
    if (!audioEl) return;

    const onTimeUpdate = () => {
      setCurrentTime(audioEl.currentTime);
      if (audioEl.duration && !isNaN(audioEl.duration)) {
        setDuration(audioEl.duration);
      }
    };

    const onEnded = () => {
      if (repeat === 'one') {
        audioEl.currentTime = 0;
        audioEl.play();
      } else {
        nextTrack();
      }
    };

    const onError = () => {
      console.warn('Audio playback error, falling back to synthesizer demo mode');
      if (currentTrack) {
        globalAudioEngine.startSynth(currentTrack.hue || 210);
      }
    };

    audioEl.addEventListener('timeupdate', onTimeUpdate);
    audioEl.addEventListener('ended', onEnded);
    audioEl.addEventListener('error', onError);

    return () => {
      audioEl.removeEventListener('timeupdate', onTimeUpdate);
      audioEl.removeEventListener('ended', onEnded);
      audioEl.removeEventListener('error', onError);
    };
  }, [repeat, currentTrack]);

  // Handle synth time increments when playing a demo track
  useEffect(() => {
    if (isPlaying && currentTrack?.is_demo) {
      synthTimerRef.current = window.setInterval(() => {
        setCurrentTime((prev) => {
          if (prev >= duration) {
            if (repeat === 'one') return 0;
            nextTrack();
            return 0;
          }
          return prev + 1;
        });
      }, 1000);
    } else {
      if (synthTimerRef.current) {
        clearInterval(synthTimerRef.current);
        synthTimerRef.current = null;
      }
    }
    return () => {
      if (synthTimerRef.current) clearInterval(synthTimerRef.current);
    };
  }, [isPlaying, currentTrack, duration, repeat]);

  const playTrack = (track: Track, newQueue?: Track[]) => {
    setCurrentTrack(track);
    setCurrentTime(0);
    setDuration(track.duration || 180);
    setIsPlaying(true);

    if (newQueue) {
      setQueue(newQueue);
    } else if (!queue.some((t) => t.id === track.id)) {
      setQueue((prev) => [track, ...prev]);
    }

    if (track.stream_url) {
      globalAudioEngine.playStream(track.stream_url).catch((err) => {
        console.warn('Stream play failed, switching to synthesizer:', err);
        globalAudioEngine.startSynth(track.hue || 210);
      });
    } else {
      globalAudioEngine.startSynth(track.hue || 210);
    }
  };

  const togglePlay = () => {
    if (!currentTrack) {
      if (queue.length > 0) playTrack(queue[0]);
      return;
    }

    if (isPlaying) {
      globalAudioEngine.pauseStream();
      setIsPlaying(false);
    } else {
      setIsPlaying(true);
      if (currentTrack.stream_url) {
        globalAudioEngine.playStream(currentTrack.stream_url, currentTime).catch(() => {
          globalAudioEngine.startSynth(currentTrack.hue || 210);
        });
      } else {
        globalAudioEngine.startSynth(currentTrack.hue || 210);
      }
    }
  };

  const nextTrack = () => {
    if (queue.length === 0) return;
    const currentIndex = queue.findIndex((t) => t.id === currentTrack?.id);
    let nextIndex = 0;

    if (shuffle) {
      nextIndex = Math.floor(Math.random() * queue.length);
    } else if (currentIndex !== -1) {
      nextIndex = currentIndex + 1;
      if (nextIndex >= queue.length) {
        if (repeat === 'all') nextIndex = 0;
        else {
          setIsPlaying(false);
          globalAudioEngine.pauseStream();
          return;
        }
      }
    }

    playTrack(queue[nextIndex]);
  };

  const prevTrack = () => {
    // If more than 3s in, restarts current track
    if (currentTime > 3) {
      seek(0);
      return;
    }

    if (queue.length === 0) return;
    const currentIndex = queue.findIndex((t) => t.id === currentTrack?.id);
    let prevIndex = queue.length - 1;

    if (currentIndex > 0) {
      prevIndex = currentIndex - 1;
    }
    playTrack(queue[prevIndex]);
  };

  const seek = (time: number) => {
    setCurrentTime(time);
    if (currentTrack?.stream_url) {
      globalAudioEngine.seekStream(time);
    }
  };

  const toggleShuffle = () => setShuffle((prev) => !prev);

  const toggleRepeat = () => {
    setRepeat((prev) => {
      if (prev === 'off') return 'all';
      if (prev === 'all') return 'one';
      return 'off';
    });
  };

  const toggleLike = (track: Track) => {
    const isCurrentlyLiked = likedIds.includes(track.id);
    let updatedIds: string[];
    let updatedTracks: Track[];

    if (isCurrentlyLiked) {
      updatedIds = likedIds.filter((id) => id !== track.id);
      updatedTracks = likedTracks.filter((t) => t.id !== track.id);
      // Optional async delete to backend
      fetch(`${API_BASE}/api/likes/${track.id}`, { method: 'DELETE' }).catch(() => {});
    } else {
      updatedIds = [...likedIds, track.id];
      updatedTracks = [track, ...likedTracks];
      // Sync like to backend
      fetch(`${API_BASE}/api/likes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          id: track.id,
          title: track.title,
          artist: track.artist,
          album: track.album || '',
          duration: track.duration || 0,
          image: track.image || '',
          stream_url: track.stream_url || '',
        }),
      }).catch(() => {});
    }

    setLikedIds(updatedIds);
    setLikedTracks(updatedTracks);
    try {
      localStorage.setItem('folio_likes', JSON.stringify(updatedIds));
    } catch {
      // Ignored
    }
  };

  const addToQueue = (track: Track) => {
    setQueue((prev) => [...prev, track]);
  };

  const removeFromQueue = (index: number) => {
    setQueue((prev) => prev.filter((_, i) => i !== index));
  };

  const isLiked = (id: string) => likedIds.includes(id);

  // Global Keyboard Shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Ignore if user is typing in an input or textarea
      if (['INPUT', 'TEXTAREA'].includes((e.target as HTMLElement)?.tagName)) {
        return;
      }

      if (e.code === 'Space') {
        e.preventDefault();
        togglePlay();
      } else if (e.altKey && e.code === 'ArrowRight') {
        e.preventDefault();
        nextTrack();
      } else if (e.altKey && e.code === 'ArrowLeft') {
        e.preventDefault();
        prevTrack();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  });

  return (
    <AudioContext.Provider
      value={{
        currentTrack,
        isPlaying,
        currentTime,
        duration,
        volume,
        shuffle,
        repeat,
        queue,
        likedIds,
        likedTracks,
        playTrack,
        togglePlay,
        nextTrack,
        prevTrack,
        seek,
        setVolume: handleSetVolume,
        toggleShuffle,
        toggleRepeat,
        toggleLike,
        addToQueue,
        removeFromQueue,
        isLiked,
      }}
    >
      {children}
    </AudioContext.Provider>
  );
};

export const useAudio = () => {
  const context = useContext(AudioContext);
  if (!context) throw new Error('useAudio must be used within AudioProvider');
  return context;
};
