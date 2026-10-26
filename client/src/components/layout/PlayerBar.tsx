import React from 'react';
import {
  Heart,
  LoaderCircle,
  Moon,
  Pause,
  Play,
  Repeat,
  Repeat1,
  Shuffle,
  SkipBack,
  SkipForward,
} from 'lucide-react';
import { useAudio } from '../../context/AudioContext';
import { useTheme } from '../../context/ThemeContext';

interface PlayerBarProps {
  onOpenPlayer: () => void;
}

const formatTime = (seconds: number) => {
  if (!Number.isFinite(seconds) || seconds < 0) return '0:00';
  const minutes = Math.floor(seconds / 60);
  const remainder = Math.floor(seconds % 60);
  return `${minutes}:${remainder.toString().padStart(2, '0')}`;
};

export const PlayerBar: React.FC<PlayerBarProps> = ({ onOpenPlayer }) => {
  const {
    currentTrack,
    isPlaying,
    isBuffering,
    currentTime,
    duration,
    shuffle,
    repeat,
    togglePlay,
    nextTrack,
    prevTrack,
    seek,
    toggleShuffle,
    toggleRepeat,
    toggleLike,
    isLiked,
  } = useAudio();
  const { sleepRemainingSeconds } = useTheme();

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 flex h-16 items-center justify-between border-t border-rule bg-paper px-3 pb-[env(safe-area-inset-bottom)] shadow-[0_-4px_16px_rgba(0,0,0,0.12)] md:h-20 md:px-6 md:pb-0">
      {currentTrack ? (
        <>
          <div className="flex min-w-0 flex-1 items-center gap-2.5 md:w-1/4 md:max-w-[260px] md:flex-none md:gap-3">
            <button
              type="button"
              onClick={onOpenPlayer}
              className="flex min-w-0 flex-1 items-center gap-2.5 text-left md:gap-3"
              aria-label={`Open player for ${currentTrack.title}`}
            >
              <span className="relative h-10 w-10 shrink-0 overflow-hidden rounded-[3px] bg-paper2 shadow-sm md:h-12 md:w-12">
                {currentTrack.image ? (
                  <img src={currentTrack.image} alt="" className="h-full w-full object-cover" />
                ) : (
                  <span className="flex h-full w-full items-center justify-center text-muted">
                    <Play className="h-4 w-4" />
                  </span>
                )}
              </span>
              <span className="min-w-0 flex-1 overflow-hidden">
                <span className="block truncate font-serif text-sm font-semibold leading-tight text-text">
                  {currentTrack.title}
                </span>
                <span className="mt-0.5 block truncate text-xs text-muted">{currentTrack.artist}</span>
              </span>
            </button>
            <button
              type="button"
              onClick={() => toggleLike(currentTrack)}
              className={`hidden h-9 w-9 shrink-0 items-center justify-center rounded transition-colors md:inline-flex ${
                isLiked(currentTrack.id) ? 'text-stamp' : 'text-muted hover:text-ink'
              }`}
              aria-label={isLiked(currentTrack.id) ? 'Unlike track' : 'Like track'}
              title={isLiked(currentTrack.id) ? 'Unlike track' : 'Like track'}
            >
              <Heart
                className={`h-4 w-4 ${isLiked(currentTrack.id) ? 'fill-current' : ''}`}
              />
            </button>
          </div>

          <div className="hidden max-w-xl flex-1 flex-col items-center px-2 md:flex">
            <div className="mb-1 flex items-center gap-4">
              <button
                type="button"
                onClick={toggleShuffle}
                className={`rounded p-1.5 transition-colors ${shuffle ? 'text-ink' : 'text-muted hover:text-ink'}`}
                title="Shuffle queue"
                aria-label="Shuffle queue"
                aria-pressed={shuffle}
              >
                <Shuffle className="h-4 w-4" />
              </button>
              <button type="button" onClick={prevTrack} className="rounded p-1.5 text-text hover:text-ink" title="Previous track" aria-label="Previous track">
                <SkipBack className="h-4 w-4" />
              </button>
              <button
                type="button"
                onClick={togglePlay}
                className="btn-tactile btn-round-tactile flex h-9 w-9 items-center justify-center shadow-md"
                title={isPlaying ? 'Pause' : 'Play'}
                aria-label={isPlaying ? 'Pause' : 'Play'}
              >
                {isBuffering ? (
                  <LoaderCircle className="h-4 w-4 animate-spin text-paper" />
                ) : isPlaying ? (
                  <Pause className="h-4 w-4 fill-current text-paper" />
                ) : (
                  <Play className="ml-0.5 h-4 w-4 fill-current text-paper" />
                )}
              </button>
              <button type="button" onClick={nextTrack} className="rounded p-1.5 text-text hover:text-ink" title="Next track" aria-label="Next track">
                <SkipForward className="h-4 w-4" />
              </button>
              <button
                type="button"
                onClick={toggleRepeat}
                className={`rounded p-1.5 transition-colors ${repeat !== 'off' ? 'text-ink' : 'text-muted hover:text-ink'}`}
                title={`Repeat: ${repeat}`}
                aria-label={`Repeat ${repeat}`}
              >
                {repeat === 'one' ? <Repeat1 className="h-4 w-4" /> : <Repeat className="h-4 w-4" />}
              </button>
            </div>
            <div className="flex w-full items-center gap-2 font-mono text-[10px] text-muted">
              <span className="w-9 text-right">{formatTime(currentTime)}</span>
              <input
                type="range"
                min={0}
                max={duration || 1}
                step={0.5}
                value={Math.min(currentTime, duration || 0)}
                onChange={(event) => seek(Number(event.target.value))}
                disabled={duration <= 0}
                className="h-4 flex-1 cursor-pointer accent-ink disabled:cursor-not-allowed"
                aria-label="Seek track position"
              />
              <span className="w-9">{formatTime(duration)}</span>
            </div>
          </div>

          <div className="hidden w-1/4 max-w-[220px] items-center justify-end gap-3 md:flex">
            {sleepRemainingSeconds ? (
              <span className="hidden items-center gap-1 rounded border border-rule/60 bg-paper2 px-2 py-0.5 font-mono text-[10px] text-ink lg:flex">
                <Moon className="h-3 w-3" />
                {Math.ceil(sleepRemainingSeconds / 60)}m
              </span>
            ) : null}
          </div>

          <div className="ml-2 flex shrink-0 items-center md:hidden">
            <button
              type="button"
              onClick={togglePlay}
              className="inline-flex h-11 w-11 items-center justify-center rounded-full text-ink active:bg-paper2"
              aria-label={isPlaying ? 'Pause' : 'Play'}
            >
              {isBuffering ? (
                <LoaderCircle className="h-5 w-5 animate-spin" />
              ) : isPlaying ? (
                <Pause className="h-5 w-5 fill-current" />
              ) : (
                <Play className="ml-0.5 h-5 w-5 fill-current" />
              )}
            </button>
          </div>
          <div
            className="absolute bottom-0 left-0 h-[2px] bg-ink/20 md:hidden"
            style={{ width: `${duration > 0 ? Math.min(100, (currentTime / duration) * 100) : 0}%` }}
            aria-hidden="true"
          >
            <span className="block h-full bg-ink transition-[width] duration-200" />
          </div>
        </>
      ) : (
        <button type="button" onClick={onOpenPlayer} className="text-sm text-muted hover:text-ink">
          Open player
        </button>
      )}
    </div>
  );
};
