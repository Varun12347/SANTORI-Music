import React, { useEffect, useState } from 'react';
import { Pause, Play, Sparkles } from 'lucide-react';
import { PolaroidArt } from '../components/paper/PolaroidArt';
import { RubberStamp } from '../components/paper/RubberStamp';
import { RuledNotebook } from '../components/paper/RuledNotebook';
import { PaperVisualizer } from '../components/visualizer/PaperVisualizer';
import { useAudio } from '../context/AudioContext';
import type { Track } from '../context/AudioContext';
import { useTheme } from '../context/ThemeContext';
import { API_BASE } from '../api';

export const HomePage: React.FC = () => {
  const { currentTrack, isPlaying, togglePlay, playTrack, queue, isLiked } = useAudio();
  const { config } = useTheme();
  const [shelfTracks, setShelfTracks] = useState<Track[]>([]);
  const [loadingShelf, setLoadingShelf] = useState<boolean>(true);

  // Fetch trending shelf tracks from our FastAPI backend (direct JioSaavn)
  useEffect(() => {
    fetch(`${API_BASE}/api/trending?language=hindi`)
      .then((res) => (res.ok ? res.json() : []))
      .then((data: Track[]) => {
        if (data && data.length > 0) {
          setShelfTracks(data);
        } else {
          // Fallback demo tracks if server is just starting
          setShelfTracks(queue);
        }
      })
      .catch(() => {
        setShelfTracks(queue);
      })
      .finally(() => setLoadingShelf(false));
  }, [queue]);

  const nowPlayingTilt = config.tilt === '1' ? '-rotate-[0.7deg]' : '';

  return (
    <div className="space-y-8 pb-12">
      {/* Top Banner Notice */}
      <div className="p-3 rounded-[3px] bg-paper2 border border-rule/70 flex items-center justify-between text-xs text-text shadow-sm">
        <div className="flex items-center space-x-2">
          <Sparkles className="w-4 h-4 text-ink flex-shrink-0" />
          <span>
            <strong>FOLIO & SANTORI Music:</strong> Stream real tracks from the Santori library and keep listening as you move between pages.
          </span>
        </div>
        <span className="font-mono text-[10px] text-muted hidden sm:inline">
          THEME: {config.shade.toUpperCase()}
        </span>
      </div>

      {/* Top Row: Now Playing Sheet + Up Next Notebook */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Now Playing Sheet (Tilted ~ -0.7deg) */}
        <div
          className={`lg:col-span-7 paper-sheet p-6 shadow-paper transition-transform duration-300 hover:rotate-0 ${nowPlayingTilt}`}
        >
          <div className="flex items-center justify-between mb-4 border-b border-rule/50 pb-2">
            <h2 className="font-serif font-semibold text-lg text-text">Now playing</h2>
            {currentTrack && isLiked(currentTrack.id) ? (
              <RubberStamp label="LIKED" />
            ) : (
              <span className="text-xs font-mono text-muted">DESK AUDIO</span>
            )}
          </div>

          {currentTrack ? (
            <div className="flex flex-col sm:flex-row items-center sm:items-start gap-6 pt-2">
              {/* Polaroid Art with Tape */}
              <PolaroidArt
                image={currentTrack.image}
                title={currentTrack.title}
                artist={currentTrack.artist}
                tiltAngle={config.tilt === '1' ? -1.2 : 0}
              />

              {/* Controls & Live Visualizer */}
              <div className="flex-1 w-full space-y-4 text-center sm:text-left">
                <div>
                  <h3 className="font-serif font-bold text-xl text-text leading-tight line-clamp-2">
                    {currentTrack.title}
                  </h3>
                  <p className="text-muted text-sm mt-1">{currentTrack.artist}</p>
                  {currentTrack.album ? (
                    <p className="text-muted/70 text-xs mt-0.5 italic">{currentTrack.album}</p>
                  ) : null}
                </div>

                {/* Hand-drawn Paper Visualizer */}
                <div className="py-2 bg-paper2/50 rounded-[3px] p-2 border border-rule/40">
                  <div className="flex justify-between items-center text-[10px] font-mono text-muted mb-1 px-1">
                    <span>VISUALIZER: {config.visualizer.toUpperCase()}</span>
                    <span>{isPlaying ? 'ACTIVE' : 'IDLE'}</span>
                  </div>
                  <PaperVisualizer className="w-full h-14" />
                </div>

                {/* Play Button & Type indicator */}
                <div className="flex items-center justify-center sm:justify-start space-x-3 pt-1">
                  <button
                    onClick={togglePlay}
                    className="btn-tactile px-5 py-2 text-sm flex items-center space-x-2 shadow-sm"
                  >
                    {isPlaying ? (
                      <>
                        <Pause className="w-4 h-4 fill-current" />
                        <span>Pause</span>
                      </>
                    ) : (
                      <>
                        <Play className="w-4 h-4 fill-current ml-0.5" />
                        <span>Play</span>
                      </>
                    )}
                  </button>

                  <span className="text-xs text-muted font-mono">
                    {currentTrack.stream_url || currentTrack.media_preview_url ? 'Audio stream' : 'Stream unavailable'}
                  </span>
                </div>
              </div>
            </div>
          ) : (
            <div className="py-12 text-center text-muted text-sm">
              No track currently selected. Tap any track below to play.
            </div>
          )}
        </div>

        {/* Up Next Notebook Queue */}
        <div className="lg:col-span-5">
          <RuledNotebook tracks={queue} />
        </div>
      </div>

      {/* Bottom Section: "On the shelf" Card Grid */}
      <section className="space-y-4">
        <div className="flex items-center justify-between border-b border-rule pb-2">
          <h3 className="font-serif font-bold text-xl text-text">On the shelf</h3>
          <span className="text-xs text-muted font-mono">Curated Selection</span>
        </div>

        {loadingShelf ? (
          <div className="p-8 text-center text-muted text-sm font-mono animate-pulse">
            Fetching tracks from shelf...
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
            {shelfTracks.map((track, i) => {
              // Alternating card tilt: -1.4deg / +1.1deg, straightens on hover
              const tiltDegree = config.tilt === '1' ? (i % 2 === 0 ? '-rotate-[1.4deg]' : 'rotate-[1.1deg]') : '';
              const isCurrent = currentTrack?.id === track.id;

              return (
                <div
                  key={`${track.id}-${i}`}
                  onClick={() => playTrack(track, shelfTracks)}
                  className={`paper-sheet p-3 cursor-pointer group transition-all duration-300 hover:rotate-0 hover:scale-[1.03] hover:shadow-lg ${tiltDegree} ${
                    isCurrent ? 'ring-2 ring-ink' : ''
                  }`}
                >
                  {/* Polaroid-like frame */}
                  <div className="aspect-square overflow-hidden rounded-[2px] bg-desk relative mb-2 shadow-inner">
                    <img
                      src={track.image || 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80'}
                      alt={track.title}
                      className="w-full h-full object-cover grayscale-[10%] group-hover:grayscale-0 transition-all duration-300"
                      loading="lazy"
                    />
                    <div className="absolute inset-0 bg-ink/20 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                      <div className="btn-tactile btn-round-tactile w-8 h-8 flex items-center justify-center">
                        <Play className="w-3.5 h-3.5 fill-current ml-0.5" />
                      </div>
                    </div>
                  </div>

                  <h4 className="font-serif font-semibold text-text text-xs truncate group-hover:text-ink">
                    {track.title}
                  </h4>
                  <p className="text-muted text-[11px] truncate mt-0.5">
                    {track.artist}
                  </p>
                </div>
              );
            })}
          </div>
        )}
      </section>
    </div>
  );
};
