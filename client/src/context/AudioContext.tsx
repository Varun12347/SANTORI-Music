import React, { createContext, useCallback, useContext, useEffect, useRef, useState } from 'react';
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
  isBuffering: boolean;
  playbackError: string | null;
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

export const AudioProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentTrack, setCurrentTrack] = useState<Track | null>(null);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [isBuffering, setIsBuffering] = useState<boolean>(false);
  const [playbackError, setPlaybackError] = useState<string | null>(null);
  const [currentTime, setCurrentTime] = useState<number>(0);
  const [duration, setDuration] = useState<number>(0);
  const [volume, setVolumeState] = useState<number>(0.85);
  const [shuffle, setShuffle] = useState<boolean>(false);
  const [repeat, setRepeat] = useState<RepeatMode>('off');
  const [queue, setQueue] = useState<Track[]>([]);
  const [likedIds, setLikedIds] = useState<string[]>(() => {
    try {
      const saved = localStorage.getItem('folio_likes');
      if (saved) return JSON.parse(saved);
    } catch {
      // Ignored
    }
    return [];
  });
  const [likedTracks, setLikedTracks] = useState<Track[]>([]);
  const playRequestRef = useRef(0);
  const nextTrackRef = useRef<() => void>(() => undefined);

  // Sync volume with audio engine
  const handleSetVolume = (vol: number) => {
    const nextVolume = Math.max(0, Math.min(1, vol));
    setVolumeState(nextVolume);
    globalAudioEngine.setVolume(nextVolume);
  };

  // HTML5 audio event bindings
  useEffect(() => {
    const audioEl = globalAudioEngine.getAudioElement();
    if (!audioEl) return;

    const onTimeUpdate = () => {
      setCurrentTime(audioEl.currentTime);
      if (Number.isFinite(audioEl.duration)) {
        setDuration(audioEl.duration);
      }
    };

    const onLoadedMetadata = () => {
      if (Number.isFinite(audioEl.duration)) setDuration(audioEl.duration);
      setIsBuffering(false);
    };
    const onWaiting = () => setIsBuffering(true);
    const onCanPlay = () => setIsBuffering(false);
    const onPlay = () => {
      setIsPlaying(true);
      setPlaybackError(null);
    };
    const onPause = () => setIsPlaying(false);
    const onEnded = () => {
      if (repeat === 'one') {
        audioEl.currentTime = 0;
        audioEl.play().catch((error: unknown) => {
          setIsPlaying(false);
          setPlaybackError(error instanceof Error ? error.message : 'Unable to replay this track.');
        });
      } else {
        nextTrackRef.current();
      }
    };

    const onError = () => {
      setIsPlaying(false);
      setIsBuffering(false);
      setPlaybackError('This track could not be loaded. Try another song.');
    };

    audioEl.addEventListener('timeupdate', onTimeUpdate);
    audioEl.addEventListener('loadedmetadata', onLoadedMetadata);
    audioEl.addEventListener('waiting', onWaiting);
    audioEl.addEventListener('canplay', onCanPlay);
    audioEl.addEventListener('play', onPlay);
    audioEl.addEventListener('pause', onPause);
    audioEl.addEventListener('ended', onEnded);
    audioEl.addEventListener('error', onError);

    return () => {
      audioEl.removeEventListener('timeupdate', onTimeUpdate);
      audioEl.removeEventListener('loadedmetadata', onLoadedMetadata);
      audioEl.removeEventListener('waiting', onWaiting);
      audioEl.removeEventListener('canplay', onCanPlay);
      audioEl.removeEventListener('play', onPlay);
      audioEl.removeEventListener('pause', onPause);
      audioEl.removeEventListener('ended', onEnded);
      audioEl.removeEventListener('error', onError);
    };
  }, [repeat]);

  const playTrack = useCallback((track: Track, newQueue?: Track[]) => {
    const requestId = ++playRequestRef.current;
    const streamUrl = track.stream_url || track.media_preview_url;
    setCurrentTrack(track);
    setCurrentTime(0);
    setDuration(track.duration || 0);
    setPlaybackError(null);
    setIsBuffering(Boolean(streamUrl));
    setIsPlaying(false);

    if (newQueue) {
      setQueue(newQueue);
    } else {
      setQueue((prev) => prev.some((queuedTrack) => queuedTrack.id === track.id) ? prev : [track, ...prev]);
    }

    if (streamUrl) {
      globalAudioEngine.setVolume(volume);
      globalAudioEngine.playStream(streamUrl).catch((error: unknown) => {
        if (requestId !== playRequestRef.current) return;
        setIsPlaying(false);
        setIsBuffering(false);
        setPlaybackError(
          error instanceof Error && error.name === 'NotAllowedError'
            ? 'Playback was blocked by your browser. Press play to try again.'
            : 'This track could not be played. Try another song.',
        );
      });
    } else {
      globalAudioEngine.pauseStream();
      setIsBuffering(false);
      setPlaybackError('A stream is not available for this track.');
    }
  }, [volume]);

  const togglePlay = () => {
    if (!currentTrack) {
      if (queue.length > 0) playTrack(queue[0]);
      return;
    }

    if (isPlaying) {
      globalAudioEngine.pauseStream();
      setIsPlaying(false);
    } else {
      const streamUrl = currentTrack.stream_url || currentTrack.media_preview_url;
      if (streamUrl) {
        setPlaybackError(null);
        setIsBuffering(true);
        globalAudioEngine.setVolume(volume);
        globalAudioEngine.playStream(streamUrl, currentTime).catch((error: unknown) => {
          setIsPlaying(false);
          setIsBuffering(false);
          setPlaybackError(
            error instanceof Error && error.name === 'NotAllowedError'
              ? 'Playback was blocked by your browser. Press play to try again.'
              : 'This track could not be played. Try another song.',
          );
        });
      } else {
        setPlaybackError('A stream is not available for this track.');
      }
    }
  };

  const nextTrack = useCallback(() => {
    if (queue.length === 0) return;
    const currentIndex = queue.findIndex((t) => t.id === currentTrack?.id);
    let nextIndex = currentIndex === -1 ? 0 : currentIndex + 1;

    if (shuffle) {
      const choices = queue.filter((track) => track.id !== currentTrack?.id);
      if (choices.length > 0) {
        playTrack(choices[Math.floor(Math.random() * choices.length)]);
        return;
      }
    }

    if (nextIndex >= queue.length) {
      if (repeat === 'all') nextIndex = 0;
      else {
        setIsPlaying(false);
        globalAudioEngine.pauseStream();
        return;
      }
    }

    playTrack(queue[nextIndex]);
  }, [queue, currentTrack, shuffle, repeat, playTrack]);

  useEffect(() => {
    nextTrackRef.current = nextTrack;
  }, [nextTrack]);

  const prevTrack = () => {
    // If more than 3s in, restarts current track
    if (currentTime > 3) {
      seek(0);
      return;
    }

    if (queue.length === 0) return;
    const currentIndex = queue.findIndex((t) => t.id === currentTrack?.id);
    if (currentIndex > 0) {
      playTrack(queue[currentIndex - 1]);
    } else if (currentIndex === 0 && repeat === 'all') {
      playTrack(queue[queue.length - 1]);
    }
  };

  const seek = (time: number) => {
    const nextTime = Math.max(0, Math.min(duration || time, time));
    globalAudioEngine.seekStream(nextTime);
    setCurrentTime(nextTime);
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
        isBuffering,
        playbackError,
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
