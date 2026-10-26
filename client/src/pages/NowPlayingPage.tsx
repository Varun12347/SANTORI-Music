import React from 'react';
import {
  AlertCircle,
  ArrowLeft,
  AudioLines,
  Heart,
  ListMusic,
  LoaderCircle,
  Music2,
  Pause,
  Play,
  Repeat,
  Repeat1,
  Shuffle,
  SkipBack,
  SkipForward,
} from 'lucide-react';
import { useAudio } from '../context/AudioContext';

interface NowPlayingPageProps {
  onBack: () => void;
}

const formatTime = (seconds: number) => {
  if (!Number.isFinite(seconds) || seconds < 0) return '0:00';
  const minutes = Math.floor(seconds / 60);
  const remainder = Math.floor(seconds % 60);
  return `${minutes}:${remainder.toString().padStart(2, '0')}`;
};

export const NowPlayingPage: React.FC<NowPlayingPageProps> = ({ onBack }) => {
  const {
    currentTrack,
    isPlaying,
    isBuffering,
    playbackError,
    currentTime,
    duration,
    shuffle,
    repeat,
    queue,
    likedIds,
    togglePlay,
    nextTrack,
    prevTrack,
    seek,
    toggleShuffle,
    toggleRepeat,
    toggleLike,
    playTrack,
  } = useAudio();

  const currentIndex = queue.findIndex((track) => track.id === currentTrack?.id);
  const liked = currentTrack ? likedIds.includes(currentTrack.id) : false;

  return (
    <section className="now-playing-page -m-4 min-h-[calc(100vh-8rem)] rounded-[4px] p-4 text-white md:-m-8 md:min-h-[calc(100vh-5rem)] md:p-8">
      <div className="mx-auto max-w-6xl">
        <div className="mb-6 flex items-center justify-between">
          <button
            type="button"
            onClick={onBack}
            className="inline-flex min-h-11 items-center gap-2 rounded-full px-3 text-sm text-white/70 transition hover:bg-white/10 hover:text-white"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to listening
          </button>
          <div className="hidden items-center gap-2 font-mono text-[10px] tracking-[0.2em] text-white/45 sm:flex">
            <AudioLines className="h-4 w-4" />
            SANTORI / NOW PLAYING
          </div>
        </div>

        <div className="grid items-start gap-8 min-[900px]:grid-cols-[minmax(0,1fr)_minmax(260px,0.72fr)] min-[900px]:gap-5">
          <div className="mx-auto w-full max-w-xl">
            <div className="now-playing-art mx-auto mb-8 aspect-square w-full max-w-[min(74vw,390px)] overflow-hidden rounded-[5px] shadow-2xl shadow-black/40">
              {currentTrack?.image ? (
                <img
                  src={currentTrack.image}
                  alt={`${currentTrack.title} cover`}
                  className="h-full w-full object-cover"
                />
              ) : (
                <div className="flex h-full w-full flex-col items-center justify-center gap-4 bg-white/[0.06] text-white/35">
                  <Music2 className="h-16 w-16" strokeWidth={1} />
                  <span className="font-mono text-[10px] tracking-[0.25em]">SANTORI AUDIO</span>
                </div>
              )}
              {isBuffering ? (
                <div className="absolute inset-0 flex items-center justify-center bg-black/35" aria-label="Loading audio">
                  <LoaderCircle className="h-9 w-9 animate-spin text-white" />
                </div>
              ) : null}
            </div>

            <div className="flex items-start justify-between gap-4">
              <div className="min-w-0">
                <p className="mb-2 font-mono text-[10px] uppercase tracking-[0.24em] text-white/45">
                  {isBuffering ? 'Connecting to stream' : isPlaying ? 'Now playing' : 'Ready when you are'}
                </p>
                <h1 className="truncate font-serif text-2xl font-semibold tracking-tight sm:text-3xl">
                  {currentTrack?.title || 'Choose a song'}
                </h1>
                <p className="mt-1 truncate text-sm text-white/65">
                  {currentTrack?.artist || 'Your next favorite is waiting'}
                </p>
                {currentTrack?.album ? (
                  <p className="mt-1 truncate text-xs text-white/40">{currentTrack.album}</p>
                ) : null}
              </div>
              {currentTrack ? (
                <button
                  type="button"
                  onClick={() => toggleLike(currentTrack)}
                  className={`mt-5 inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-full transition hover:bg-white/10 ${
                    liked ? 'text-rose-300' : 'text-white/55 hover:text-white'
                  }`}
                  aria-label={liked ? 'Unlike track' : 'Like track'}
                  title={liked ? 'Unlike track' : 'Like track'}
                >
                  <Heart className={`h-5 w-5 ${liked ? 'fill-current' : ''}`} />
                </button>
              ) : null}
            </div>

            {playbackError ? (
              <div className="mt-5 flex items-start gap-2 rounded-md border border-rose-300/20 bg-rose-300/[0.08] px-3 py-2.5 text-sm text-rose-100/90" role="status">
                <AlertCircle className="mt-0.5 h-4 w-4 shrink-0" />
                <span>{playbackError}</span>
              </div>
            ) : null}

            <div className="mt-7">
              <input
                type="range"
                min={0}
                max={duration || 1}
                step={0.1}
                value={Math.min(currentTime, duration || 0)}
                onChange={(event) => {
                  const value = Number(event.target.value);
                  seek(value);
                }}
                disabled={!currentTrack || duration <= 0}
                className="now-playing-range h-8 w-full cursor-pointer disabled:cursor-not-allowed disabled:opacity-40"
                aria-label="Seek track position"
              />
              <div className="-mt-1 flex justify-between font-mono text-[11px] text-white/45">
                <span>{formatTime(currentTime)}</span>
                <span>{formatTime(duration)}</span>
              </div>
            </div>

            <div className="mt-5 flex items-center justify-between gap-3">
              <button
                type="button"
                onClick={toggleShuffle}
                className={`inline-flex h-11 w-11 items-center justify-center rounded-full transition hover:bg-white/10 ${
                  shuffle ? 'text-emerald-300' : 'text-white/45 hover:text-white'
                }`}
                aria-label={shuffle ? 'Turn shuffle off' : 'Turn shuffle on'}
                aria-pressed={shuffle}
              >
                <Shuffle className="h-5 w-5" />
              </button>
              <div className="flex items-center gap-3 sm:gap-5">
                <button
                  type="button"
                  onClick={prevTrack}
                  disabled={!currentTrack}
                  className="inline-flex h-12 w-12 items-center justify-center rounded-full text-white/80 transition hover:scale-105 hover:text-white disabled:opacity-35"
                  aria-label="Previous track"
                >
                  <SkipBack className="h-6 w-6 fill-current" />
                </button>
                <button
                  type="button"
                  onClick={togglePlay}
                  disabled={!currentTrack}
                  className="inline-flex h-16 w-16 items-center justify-center rounded-full bg-white text-[#191a1a] shadow-xl shadow-black/20 transition hover:scale-105 disabled:opacity-40"
                  aria-label={isPlaying ? 'Pause' : 'Play'}
                >
                  {isBuffering ? (
                    <LoaderCircle className="h-7 w-7 animate-spin" />
                  ) : isPlaying ? (
                    <Pause className="h-7 w-7 fill-current" />
                  ) : (
                    <Play className="ml-1 h-7 w-7 fill-current" />
                  )}
                </button>
                <button
                  type="button"
                  onClick={nextTrack}
                  disabled={!currentTrack}
                  className="inline-flex h-12 w-12 items-center justify-center rounded-full text-white/80 transition hover:scale-105 hover:text-white disabled:opacity-35"
                  aria-label="Next track"
                >
                  <SkipForward className="h-6 w-6 fill-current" />
                </button>
              </div>
              <button
                type="button"
                onClick={toggleRepeat}
                className={`inline-flex h-11 w-11 items-center justify-center rounded-full transition hover:bg-white/10 ${
                  repeat !== 'off' ? 'text-emerald-300' : 'text-white/45 hover:text-white'
                }`}
                aria-label={`Repeat ${repeat}`}
                aria-pressed={repeat !== 'off'}
                title={`Repeat: ${repeat}`}
              >
                {repeat === 'one' ? <Repeat1 className="h-5 w-5" /> : <Repeat className="h-5 w-5" />}
              </button>
            </div>

          </div>

          <section className="rounded-lg border border-white/10 bg-black/15 p-4 sm:p-5" aria-labelledby="queue-title">
            <div className="mb-4 flex items-center justify-between border-b border-white/10 pb-4">
              <div>
                <div className="mb-1 flex items-center gap-2 text-white/45">
                  <ListMusic className="h-4 w-4" />
                  <span className="font-mono text-[10px] uppercase tracking-[0.2em]">Your listening session</span>
                </div>
                <h2 id="queue-title" className="font-serif text-xl font-semibold">Queue</h2>
              </div>
              <span className="rounded-full bg-white/[0.07] px-2.5 py-1 font-mono text-[10px] text-white/55">
                {queue.length} {queue.length === 1 ? 'track' : 'tracks'}
              </span>
            </div>

            {queue.length === 0 ? (
              <div className="py-10 text-center">
                <Music2 className="mx-auto mb-3 h-8 w-8 text-white/25" />
                <p className="text-sm text-white/60">Your queue is waiting.</p>
                <p className="mt-1 text-xs text-white/35">Play a song from Search or your Library.</p>
              </div>
            ) : (
              <ol className="max-h-[min(52vh,520px)] space-y-1 overflow-y-auto pr-1">
                {queue.map((track, index) => {
                  const isCurrent = track.id === currentTrack?.id;
                  const isUpcoming = currentIndex >= 0 && index > currentIndex;
                  return (
                    <li key={`${track.id}-${index}`}>
                      <button
                        type="button"
                        onClick={() => {
                          if (isCurrent) togglePlay();
                          else playTrack(track, queue);
                        }}
                        className={`group flex min-h-[64px] w-full items-center gap-3 rounded-md px-2.5 text-left transition hover:bg-white/[0.07] ${
                          isCurrent ? 'bg-white/[0.08]' : ''
                        }`}
                        aria-current={isCurrent ? 'true' : undefined}
                      >
                        <div className="relative h-11 w-11 shrink-0 overflow-hidden rounded bg-white/[0.07]">
                          {track.image ? (
                            <img src={track.image} alt="" className="h-full w-full object-cover" loading="lazy" />
                          ) : (
                            <div className="flex h-full w-full items-center justify-center text-white/35">
                              <Music2 className="h-5 w-5" />
                            </div>
                          )}
                          {isCurrent && isPlaying ? (
                            <div className="absolute inset-0 flex items-center justify-center bg-black/45">
                              <AudioLines className="h-5 w-5 text-white" />
                            </div>
                          ) : null}
                        </div>
                        <span className="min-w-0 flex-1">
                          <span className={`block truncate text-sm ${isCurrent ? 'font-medium text-emerald-200' : 'text-white/85'}`}>
                            {track.title}
                          </span>
                          <span className="mt-0.5 block truncate text-xs text-white/45">
                            {track.artist}{track.album ? ` · ${track.album}` : ''}
                          </span>
                        </span>
                        <span className="shrink-0 font-mono text-[9px] uppercase tracking-wider text-white/35">
                          {isCurrent ? 'Playing' : isUpcoming ? 'Up next' : formatTime(track.duration || 0)}
                        </span>
                      </button>
                    </li>
                  );
                })}
              </ol>
            )}
          </section>
        </div>
      </div>
    </section>
  );
};
