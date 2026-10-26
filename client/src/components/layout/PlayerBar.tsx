import React from 'react';
import {
  Heart,
  Moon,
  Pause,
  Play,
  Repeat,
  Repeat1,
  Shuffle,
  SkipBack,
  SkipForward,
  Volume2,
  VolumeX,
} from 'lucide-react';
import { useAudio } from '../../context/AudioContext';
import { useTheme } from '../../context/ThemeContext';

export const PlayerBar: React.FC = () => {
  const {
    currentTrack,
    isPlaying,
    currentTime,
    duration,
    volume,
    shuffle,
    repeat,
    togglePlay,
    nextTrack,
    prevTrack,
    seek,
    setVolume,
    toggleShuffle,
    toggleRepeat,
    toggleLike,
    isLiked,
  } = useAudio();

  const { sleepRemainingSeconds } = useTheme();

  const formatTime = (secs: number) => {
    if (isNaN(secs) || secs < 0) return '0:00';
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  };

  const handleSeekChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    seek(parseFloat(e.target.value));
  };

  const liked = currentTrack ? isLiked(currentTrack.id) : false;

  return (
    <div className="fixed bottom-0 left-0 right-0 z-40 perforated-bar h-20 px-4 md:px-6 flex items-center justify-between select-none">
      {/* Left: Track Details */}
      <div className="flex items-center space-x-3 w-1/4 min-w-[170px] max-w-[260px]">
        {currentTrack ? (
          <>
            <div className="w-12 h-12 rounded-[2px] overflow-hidden bg-desk flex-shrink-0 shadow-sm relative">
              {currentTrack.image ? (
                <img
                  src={currentTrack.image}
                  alt={currentTrack.title}
                  className="w-full h-full object-cover grayscale-[10%]"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center font-mono text-[9px] text-muted">
                  FOLIO
                </div>
              )}
            </div>
            <div className="overflow-hidden pr-2">
              <h4 className="font-serif font-semibold text-text text-sm truncate leading-tight">
                {currentTrack.title}
              </h4>
              <p className="text-muted text-xs truncate mt-0.5">
                {currentTrack.artist}
              </p>
              {currentTrack.is_demo ? (
                <span className="text-[9px] font-mono text-muted/80 block mt-0.5">
                  Demo tone
                </span>
              ) : null}
            </div>
            <button
              onClick={() => toggleLike(currentTrack)}
              className={`p-1.5 rounded transition-transform active:scale-90 ${
                liked ? 'text-stamp' : 'text-muted hover:text-ink'
              }`}
              title={liked ? 'Unlike track' : 'Like track'}
            >
              <Heart className={`w-4 h-4 ${liked ? 'fill-current' : ''}`} />
            </button>
          </>
        ) : (
          <div className="text-xs text-muted">No track loaded</div>
        )}
      </div>

      {/* Center: Playback Controls & Real Seek Bar */}
      <div className="flex flex-col items-center flex-1 max-w-xl px-2">
        {/* Buttons */}
        <div className="flex items-center space-x-4 mb-1">
          {/* Shuffle (hidden on mobile) */}
          <button
            onClick={toggleShuffle}
            className={`hidden sm:inline-flex p-1.5 rounded text-xs transition-colors ${
              shuffle ? 'text-ink font-bold' : 'text-muted hover:text-ink'
            }`}
            title="Shuffle queue"
          >
            <Shuffle className="w-3.5 h-3.5" />
          </button>

          {/* Previous */}
          <button
            onClick={prevTrack}
            className="p-1.5 rounded text-text hover:text-ink transition-transform active:scale-95"
            title="Previous track (or restart)"
          >
            <SkipBack className="w-4 h-4" />
          </button>

          {/* Play / Pause Tactile Round Button */}
          <button
            onClick={togglePlay}
            className="btn-tactile btn-round-tactile w-9 h-9 flex items-center justify-center shadow-md focus:outline-none"
            title={isPlaying ? 'Pause (Space)' : 'Play (Space)'}
          >
            {isPlaying ? (
              <Pause className="w-4 h-4 text-paper fill-current" />
            ) : (
              <Play className="w-4 h-4 text-paper fill-current ml-0.5" />
            )}
          </button>

          {/* Next */}
          <button
            onClick={nextTrack}
            className="p-1.5 rounded text-text hover:text-ink transition-transform active:scale-95"
            title="Next track"
          >
            <SkipForward className="w-4 h-4" />
          </button>

          {/* Repeat (hidden on mobile) */}
          <button
            onClick={toggleRepeat}
            className={`hidden sm:inline-flex p-1.5 rounded text-xs transition-colors ${
              repeat !== 'off' ? 'text-ink font-bold' : 'text-muted hover:text-ink'
            }`}
            title={`Repeat: ${repeat}`}
          >
            {repeat === 'one' ? <Repeat1 className="w-3.5 h-3.5" /> : <Repeat className="w-3.5 h-3.5" />}
          </button>
        </div>

        {/* Seek Bar & Timers */}
        <div className="w-full flex items-center space-x-2 text-[11px] font-mono text-muted">
          <span className="w-9 text-right select-none">{formatTime(currentTime)}</span>
          <input
            type="range"
            min="0"
            max={duration || 100}
            step="0.5"
            value={currentTime}
            onChange={handleSeekChange}
            className="flex-1 accent-ink h-1 cursor-pointer bg-rule/50 rounded"
            aria-label="Seek track position"
          />
          <span className="w-9 text-left select-none">{formatTime(duration)}</span>
        </div>
      </div>

      {/* Right: Volume & Sleep Timer Badge */}
      <div className="flex items-center justify-end space-x-3 w-1/4 min-w-[140px] max-w-[220px]">
        {sleepRemainingSeconds ? (
          <div
            className="hidden lg:flex items-center space-x-1 px-2 py-0.5 rounded bg-paper2 border border-rule/60 text-[10px] text-ink font-mono"
            title="Sleep timer active"
          >
            <Moon className="w-3 h-3 text-ink" />
            <span>{Math.ceil(sleepRemainingSeconds / 60)}m</span>
          </div>
        ) : null}

        <button
          onClick={() => setVolume(volume > 0 ? 0 : 0.8)}
          className="text-muted hover:text-ink p-1 rounded transition-colors"
          title="Mute / Unmute"
        >
          {volume === 0 ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
        </button>

        <input
          type="range"
          min="0"
          max="1"
          step="0.02"
          value={volume}
          onChange={(e) => setVolume(parseFloat(e.target.value))}
          className="w-16 sm:w-20 accent-ink h-1 cursor-pointer bg-rule/50 rounded"
          aria-label="Volume slider"
        />
      </div>
    </div>
  );
};
