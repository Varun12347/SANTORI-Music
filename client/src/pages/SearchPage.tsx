import React, { useEffect, useState } from 'react';
import { Heart, ListPlus, Play, Search, X } from 'lucide-react';
import { useAudio } from '../context/AudioContext';
import type { Track } from '../context/AudioContext';

const GENRE_CHIPS = ['All genres', 'Hindi', 'Punjabi', 'English', 'Lofi', 'Acoustic', 'Indie', 'Pop'];

export const SearchPage: React.FC = () => {
  const { currentTrack, playTrack, addToQueue, toggleLike, isLiked } = useAudio();
  const [query, setQuery] = useState('');
  const [activeGenre, setActiveGenre] = useState('All genres');
  const [sortBy, setSortBy] = useState<'default' | 'title' | 'artist' | 'length'>('default');
  const [results, setResults] = useState<Track[]>([]);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);

  // Debounced search trigger
  useEffect(() => {
    const q = query.trim() || (activeGenre !== 'All genres' ? activeGenre : 'Top Hits');
    const timer = setTimeout(() => {
      fetchTracks(q);
    }, 350);

    return () => clearTimeout(timer);
  }, [query, activeGenre]);

  const fetchTracks = (searchQuery: string) => {
    setLoading(true);
    setSearched(true);
    fetch(`http://127.0.0.1:8000/api/search?q=${encodeURIComponent(searchQuery)}&limit=24`)
      .then((res) => (res.ok ? res.json() : []))
      .then((data: Track[]) => {
        setResults(data || []);
      })
      .catch((err) => {
        console.warn('Search error:', err);
        setResults([]);
      })
      .finally(() => setLoading(false));
  };

  // Sorting
  const sortedResults = [...results].sort((a, b) => {
    if (sortBy === 'title') return a.title.localeCompare(b.title);
    if (sortBy === 'artist') return a.artist.localeCompare(b.artist);
    if (sortBy === 'length') return (a.duration || 0) - (b.duration || 0);
    return 0;
  });

  const formatDuration = (sec?: number) => {
    if (!sec) return '3:15';
    const m = Math.floor(sec / 60);
    const s = Math.floor(sec % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  };

  return (
    <div className="space-y-6 pb-16">
      {/* Search Header & Bar */}
      <div className="space-y-4">
        <h2 className="font-serif font-bold text-2xl text-text">Search music</h2>

        <div className="flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-muted absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search by title, artist, album or lyrics..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="w-full bg-paper pl-10 pr-10 py-2.5 rounded-[3px] border border-rule text-sm text-text placeholder:text-muted focus:outline-none focus:ring-1 focus:ring-ink shadow-sm"
            />
            {query && (
              <button
                onClick={() => setQuery('')}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-muted hover:text-text p-1"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </div>

          {/* Sort Select */}
          <div className="flex items-center space-x-2">
            <label className="text-xs text-muted font-mono whitespace-nowrap">Sort by:</label>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as 'default' | 'title' | 'artist' | 'length')}
              className="bg-paper border border-rule text-xs py-2.5 px-3 rounded-[3px] text-text focus:outline-none focus:ring-1 focus:ring-ink"
            >
              <option value="default">Default</option>
              <option value="title">Title (A-Z)</option>
              <option value="artist">Artist</option>
              <option value="length">Length</option>
            </select>
          </div>
        </div>

        {/* Genre Filter Chips */}
        <div className="flex items-center space-x-2 overflow-x-auto pb-1 pt-1 no-scrollbar">
          {GENRE_CHIPS.map((genre) => {
            const active = activeGenre === genre;
            return (
              <button
                key={genre}
                onClick={() => {
                  setActiveGenre(genre);
                  if (genre !== 'All genres') setQuery('');
                }}
                className={`px-3 py-1 rounded-[3px] text-xs font-medium border transition-colors whitespace-nowrap ${
                  active
                    ? 'bg-ink text-paper border-ink font-semibold'
                    : 'bg-paper2 text-text border-rule/60 hover:border-rule'
                }`}
              >
                {genre}
              </button>
            );
          })}
        </div>
      </div>

      {/* Results Section */}
      <div>
        {loading ? (
          <div className="py-16 text-center text-muted font-mono text-xs animate-pulse">
            Searching paper archives and JioSaavn library...
          </div>
        ) : sortedResults.length === 0 && searched ? (
          <div className="paper-sheet p-8 text-center max-w-md mx-auto my-8">
            <h4 className="font-serif font-semibold text-base text-text mb-1">Nothing found</h4>
            <p className="text-xs text-muted">
              We couldn&apos;t find any songs matching your query. Try searching for artist names like Arijit Singh, Diljit, or Taylor Swift.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {sortedResults.map((track) => {
              const isCurrent = currentTrack?.id === track.id;
              const liked = isLiked(track.id);

              return (
                <div
                  key={track.id}
                  className={`paper-sheet p-3 flex items-center justify-between rounded-[3px] border border-rule/50 hover:shadow-md transition-all group ${
                    isCurrent ? 'ring-1 ring-ink bg-paper2' : ''
                  }`}
                >
                  {/* Left: Thumbnail & Song Info */}
                  <div
                    onClick={() => playTrack(track, sortedResults)}
                    className="flex items-center space-x-3 overflow-hidden flex-1 cursor-pointer"
                  >
                    <div className="w-12 h-12 rounded-[2px] overflow-hidden bg-desk flex-shrink-0 relative">
                      <img
                        src={track.image || 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80'}
                        alt={track.title}
                        className="w-full h-full object-cover"
                        loading="lazy"
                      />
                      <div className="absolute inset-0 bg-ink/20 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                        <Play className="w-4 h-4 text-paper fill-current ml-0.5" />
                      </div>
                    </div>

                    <div className="overflow-hidden pr-2">
                      <h4 className="font-serif font-semibold text-sm text-text truncate group-hover:text-ink">
                        {track.title}
                      </h4>
                      <p className="text-xs text-muted truncate mt-0.5">
                        {track.artist}
                      </p>
                      <span className="text-[10px] font-mono text-muted/70 block mt-0.5">
                        {formatDuration(track.duration)}
                      </span>
                    </div>
                  </div>

                  {/* Right Actions: Queue & Like */}
                  <div className="flex items-center space-x-1 pl-2">
                    <button
                      onClick={() => addToQueue(track)}
                      className="p-1.5 rounded hover:bg-black/10 dark:hover:bg-white/10 text-muted hover:text-ink transition-colors"
                      title="Add to queue"
                    >
                      <ListPlus className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => toggleLike(track)}
                      className={`p-1.5 rounded transition-transform active:scale-90 ${
                        liked ? 'text-stamp' : 'text-muted hover:text-ink'
                      }`}
                      title={liked ? 'Liked' : 'Like'}
                    >
                      <Heart className={`w-4 h-4 ${liked ? 'fill-current' : ''}`} />
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};
