import React from 'react';
import { Play, Trash2 } from 'lucide-react';
import { useAudio } from '../../context/AudioContext';
import type { Track } from '../../context/AudioContext';
import { useTheme } from '../../context/ThemeContext';

interface RuledNotebookProps {
  tracks: Track[];
  className?: string;
}

export const RuledNotebook: React.FC<RuledNotebookProps> = ({ tracks, className = '' }) => {
  const { currentTrack, isPlaying, playTrack, togglePlay, removeFromQueue } = useAudio();
  const { config } = useTheme();

  const tiltClass = config.tilt === '1' ? 'rotate-[0.5deg]' : '';

  const formatTime = (sec?: number) => {
    if (!sec) return '3:15';
    const m = Math.floor(sec / 60);
    const s = Math.floor(sec % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  };

  return (
    <div
      className={`ruled-notebook paper-sheet p-6 pt-5 min-h-[340px] shadow-paper transition-transform duration-300 hover:rotate-0 ${tiltClass} ${className}`}
    >
      <div className="flex items-center justify-between pb-3 pl-12 border-b border-rule/50 mb-2">
        <h3 className="font-serif font-semibold text-lg text-text">Up next</h3>
        <span className="text-xs text-muted font-mono">{tracks.length} queued</span>
      </div>

      {tracks.length === 0 ? (
        <div className="pl-14 py-8 text-sm text-muted">
          Your notebook is empty. Search tracks and tap play to queue them.
        </div>
      ) : (
        <div className="space-y-0">
          {tracks.slice(0, 7).map((track, idx) => {
            const isCurrent = currentTrack?.id === track.id;
            return (
              <div
                key={`${track.id}-${idx}`}
                className={`group flex items-center justify-between h-8 text-sm px-2 rounded hover:bg-black/5 dark:hover:bg-white/5 transition-colors ${
                  isCurrent ? 'font-semibold text-ink' : 'text-text'
                }`}
              >
                {/* Left side: Sequence Number + Margin spacing + Title */}
                <div className="flex items-center space-x-3 overflow-hidden pr-2">
                  <span className="w-8 text-right font-mono text-xs text-muted group-hover:text-ink select-none">
                    {idx + 1}.
                  </span>
                  <div className="w-3" /> {/* Margin line gap */}
                  <button
                    onClick={() => {
                      if (isCurrent) togglePlay();
                      else playTrack(track);
                    }}
                    className="truncate text-left hover:underline flex items-center space-x-1.5 focus:outline-none"
                    title={track.title}
                  >
                    {isCurrent && isPlaying ? (
                      <span className="w-1.5 h-1.5 rounded-full bg-ink animate-pulse inline-block" />
                    ) : null}
                    <span className="truncate">{track.title}</span>
                  </button>
                  <span className="text-xs text-muted truncate hidden sm:inline">— {track.artist}</span>
                </div>

                {/* Right side: Duration & Action Buttons */}
                <div className="flex items-center space-x-2 pl-2">
                  <span className="text-xs font-mono text-muted">{formatTime(track.duration)}</span>
                  <button
                    onClick={() => playTrack(track)}
                    className="p-1 rounded opacity-0 group-hover:opacity-100 hover:bg-black/10 dark:hover:bg-white/10 transition-opacity"
                    title="Play track"
                  >
                    <Play className="w-3.5 h-3.5 text-ink" />
                  </button>
                  <button
                    onClick={() => removeFromQueue(idx)}
                    className="p-1 rounded opacity-0 group-hover:opacity-100 hover:text-red-600 transition-opacity"
                    title="Remove from queue"
                  >
                    <Trash2 className="w-3.5 h-3.5 text-muted" />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
