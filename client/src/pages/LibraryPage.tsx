import React, { useEffect, useState } from 'react';
import { FolderPlus, Heart, ListMusic, Play, Trash2 } from 'lucide-react';
import { RubberStamp } from '../components/paper/RubberStamp';
import { useAudio } from '../context/AudioContext';
import type { Track } from '../context/AudioContext';

interface PlaylistData {
  id: number;
  name: string;
  description: string;
  track_count: number;
  tracks: Track[];
}

export const LibraryPage: React.FC = () => {
  const { likedTracks, playTrack, toggleLike } = useAudio();
  const [activeTab, setActiveTab] = useState<'likes' | 'playlists'>('likes');
  const [playlists, setPlaylists] = useState<PlaylistData[]>([]);
  const [newPlaylistName, setNewPlaylistName] = useState('');
  const [newPlaylistDesc, setNewPlaylistDesc] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);

  useEffect(() => {
    fetchPlaylists();
  }, []);

  const fetchPlaylists = () => {
    fetch('http://127.0.0.1:8000/api/playlists')
      .then((res) => (res.ok ? res.json() : []))
      .then((data) => setPlaylists(data || []))
      .catch(() => {});
  };

  const handleCreatePlaylist = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newPlaylistName.trim()) return;

    fetch('http://127.0.0.1:8000/api/playlists', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: newPlaylistName, description: newPlaylistDesc }),
    })
      .then((res) => (res.ok ? res.json() : null))
      .then(() => {
        setNewPlaylistName('');
        setNewPlaylistDesc('');
        setShowCreateModal(false);
        fetchPlaylists();
      })
      .catch(() => {});
  };

  const handleDeletePlaylist = (id: number) => {
    fetch(`http://127.0.0.1:8000/api/playlists/${id}`, { method: 'DELETE' })
      .then(() => fetchPlaylists())
      .catch(() => {});
  };

  return (
    <div className="space-y-6 pb-16">
      {/* Library Tabs */}
      <div className="flex items-center justify-between border-b border-rule pb-3">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => setActiveTab('likes')}
            className={`font-serif text-xl transition-colors pb-1 flex items-center space-x-2 ${
              activeTab === 'likes' ? 'font-bold text-ink border-b-2 border-ink' : 'text-muted hover:text-text'
            }`}
          >
            <Heart className="w-4 h-4" />
            <span>Liked tracks</span>
            <span className="text-xs font-mono text-muted">({likedTracks.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('playlists')}
            className={`font-serif text-xl transition-colors pb-1 flex items-center space-x-2 ${
              activeTab === 'playlists' ? 'font-bold text-ink border-b-2 border-ink' : 'text-muted hover:text-text'
            }`}
          >
            <ListMusic className="w-4 h-4" />
            <span>Playlists</span>
            <span className="text-xs font-mono text-muted">({playlists.length})</span>
          </button>
        </div>

        {activeTab === 'playlists' ? (
          <button
            onClick={() => setShowCreateModal(true)}
            className="btn-tactile text-xs px-3 py-1.5 flex items-center space-x-1.5"
          >
            <FolderPlus className="w-3.5 h-3.5" />
            <span>New playlist</span>
          </button>
        ) : null}
      </div>

      {/* Tab: Liked Tracks */}
      {activeTab === 'likes' ? (
        likedTracks.length === 0 ? (
          <div className="paper-sheet p-8 text-center max-w-md mx-auto my-12">
            <h4 className="font-serif font-semibold text-base text-text mb-1">Nothing liked yet</h4>
            <p className="text-xs text-muted">
              Tap the heart on any track or in the player bar to keep a track here.
            </p>
          </div>
        ) : (
          <div className="space-y-2">
            {likedTracks.map((track, i) => (
              <div
                key={`${track.id}-${i}`}
                className="paper-sheet p-3 flex items-center justify-between hover:bg-paper2 transition-colors group"
              >
                <div
                  onClick={() => playTrack(track, likedTracks)}
                  className="flex items-center space-x-3 overflow-hidden flex-1 cursor-pointer"
                >
                  <div className="w-10 h-10 rounded-[2px] overflow-hidden bg-desk flex-shrink-0">
                    <img
                      src={track.image || 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80'}
                      alt={track.title}
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div className="overflow-hidden pr-2">
                    <h4 className="font-serif font-semibold text-sm text-text truncate group-hover:text-ink">
                      {track.title}
                    </h4>
                    <p className="text-xs text-muted truncate">{track.artist}</p>
                  </div>
                </div>

                <div className="flex items-center space-x-3 pl-2">
                  <RubberStamp label="LIKED" className="scale-75 origin-right hidden sm:inline-block" />
                  <button
                    onClick={() => toggleLike(track)}
                    className="p-1.5 text-stamp hover:opacity-75 transition-opacity"
                    title="Remove from likes"
                  >
                    <Heart className="w-4 h-4 fill-current" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )
      ) : null}

      {/* Tab: Playlists */}
      {activeTab === 'playlists' ? (
        playlists.length === 0 ? (
          <div className="paper-sheet p-8 text-center max-w-md mx-auto my-12">
            <h4 className="font-serif font-semibold text-base text-text mb-1">No playlists yet</h4>
            <p className="text-xs text-muted mb-4">
              Create your first paper playlist to organize your listening sheets.
            </p>
            <button
              onClick={() => setShowCreateModal(true)}
              className="btn-tactile text-xs px-4 py-2"
            >
              Create playlist
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
            {playlists.map((pl) => (
              <div
                key={pl.id}
                className="paper-sheet p-4 flex flex-col justify-between hover:shadow-md transition-shadow group"
              >
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[10px] font-mono text-muted uppercase">FOLIO PLAYLIST</span>
                    <button
                      onClick={() => handleDeletePlaylist(pl.id)}
                      className="p-1 text-muted hover:text-red-500 rounded opacity-0 group-hover:opacity-100 transition-opacity"
                      title="Delete playlist"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                  <h3 className="font-serif font-bold text-base text-text truncate">{pl.name}</h3>
                  <p className="text-xs text-muted line-clamp-2 mt-1">{pl.description || 'No description'}</p>
                </div>

                <div className="flex items-center justify-between pt-4 mt-3 border-t border-rule/50">
                  <span className="text-xs font-mono text-muted">{pl.track_count} tracks</span>
                  {pl.tracks && pl.tracks.length > 0 ? (
                    <button
                      onClick={() => playTrack(pl.tracks[0], pl.tracks)}
                      className="btn-tactile text-xs px-2.5 py-1 flex items-center space-x-1"
                    >
                      <Play className="w-3 h-3 fill-current" />
                      <span>Play all</span>
                    </button>
                  ) : null}
                </div>
              </div>
            ))}
          </div>
        )
      ) : null}

      {/* Create Playlist Modal */}
      {showCreateModal ? (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
          <div className="paper-sheet max-w-sm w-full p-6 shadow-2xl border border-rule">
            <h3 className="font-serif font-bold text-lg text-text mb-3">Create playlist</h3>
            <form onSubmit={handleCreatePlaylist} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-muted uppercase mb-1">
                  Playlist name
                </label>
                <input
                  type="text"
                  placeholder="e.g. Midnight Study"
                  value={newPlaylistName}
                  onChange={(e) => setNewPlaylistName(e.target.value)}
                  className="w-full text-xs p-2 bg-paper2 border border-rule/60 rounded text-text focus:outline-none focus:ring-1 focus:ring-ink"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-muted uppercase mb-1">
                  Description
                </label>
                <textarea
                  placeholder="Short note or description..."
                  rows={2}
                  value={newPlaylistDesc}
                  onChange={(e) => setNewPlaylistDesc(e.target.value)}
                  className="w-full text-xs p-2 bg-paper2 border border-rule/60 rounded text-text focus:outline-none focus:ring-1 focus:ring-ink"
                />
              </div>

              <div className="flex justify-end space-x-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="text-xs px-3 py-1.5 rounded text-muted hover:text-text"
                >
                  Cancel
                </button>
                <button type="submit" className="btn-tactile text-xs px-4 py-1.5">
                  Create
                </button>
              </div>
            </form>
          </div>
        </div>
      ) : null}
    </div>
  );
};
