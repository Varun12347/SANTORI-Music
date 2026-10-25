import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../theme/paper_tokens.dart';
import '../theme/theme_provider.dart';
import '../widgets/paper/paper_sheet.dart';
import '../widgets/paper/rubber_stamp.dart';
import '../widgets/paper/tactile_button.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _activeTab = 0; // 0: Likes, 1: Playlists
  List<Playlist> _playlists = [];
  bool _loadingPlaylists = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    final list = await ApiService.getPlaylists();
    if (mounted) {
      setState(() {
        _playlists = list;
        _loadingPlaylists = false;
      });
    }
  }

  void _showCreatePlaylistDialog(BuildContext context, ShadeTokens shade) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: shade.paper,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          title: Text(
            'Create playlist',
            style: GoogleFonts.fraunces(color: shade.text, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.karla(color: shade.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Midnight Study',
                  hintStyle: GoogleFonts.karla(color: shade.muted),
                  labelText: 'Playlist name',
                  labelStyle: GoogleFonts.karla(color: shade.muted),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: shade.rule),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: GoogleFonts.karla(color: shade.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Short note or description...',
                  hintStyle: GoogleFonts.karla(color: shade.muted),
                  labelText: 'Description',
                  labelStyle: GoogleFonts.karla(color: shade.muted),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: shade.rule),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.karla(color: shade.muted),
              ),
            ),
            TactileButton(
              label: 'Create',
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final nav = Navigator.of(ctx);
                  await ApiService.createPlaylist(nameCtrl.text, descCtrl.text);
                  nav.pop();
                  if (mounted) _fetchPlaylists();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final audio = Provider.of<AudioPlaybackService>(context);
    final shade = theme.currentShade;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        // Tabs Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTabButton(
                  title: 'Liked tracks',
                  count: audio.likedTracks.length,
                  isSelected: _activeTab == 0,
                  onTap: () => setState(() => _activeTab = 0),
                  theme: theme,
                  shade: shade,
                ),
                const SizedBox(width: 16),
                _buildTabButton(
                  title: 'Playlists',
                  count: _playlists.length,
                  isSelected: _activeTab == 1,
                  onTap: () => setState(() => _activeTab = 1),
                  theme: theme,
                  shade: shade,
                ),
              ],
            ),
            if (_activeTab == 1)
              TactileButton(
                label: 'New playlist',
                icon: Icons.add,
                onPressed: () => _showCreatePlaylistDialog(context, shade),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Tab Content
        if (_activeTab == 0)
          _buildLikedTracksTab(context, theme, audio, shade)
        else
          _buildPlaylistsTab(context, theme, audio, shade),
      ],
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeProvider theme,
    required ShadeTokens shade,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(bottom: BorderSide(color: theme.inkColor, width: 2))
              : null,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.fraunces(
                color: isSelected ? theme.inkColor : shade.muted,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: GoogleFonts.karla(color: shade.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedTracksTab(
    BuildContext context,
    ThemeProvider theme,
    AudioPlaybackService audio,
    ShadeTokens shade,
  ) {
    if (audio.likedTracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Text(
                'Nothing liked yet',
                style: GoogleFonts.fraunces(
                  color: shade.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap the heart in the player bar or track list to keep a track here.',
                style: GoogleFonts.karla(color: shade.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: audio.likedTracks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final track = audio.likedTracks[idx];

        return PaperSheet(
          enableTilt: false,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onTap: () => audio.playTrack(track, newQueue: audio.likedTracks),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: shade.desk,
                  borderRadius: BorderRadius.circular(2),
                ),
                clipBehavior: Clip.antiAlias,
                child: track.image.isNotEmpty
                    ? Image.network(track.image, fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          Icons.music_note,
                          color: shade.muted,
                          size: 16,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: GoogleFonts.fraunces(
                        color: shade.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track.artist,
                      style: GoogleFonts.karla(
                        color: shade.muted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const RubberStamp(label: 'LIKED'),
              IconButton(
                icon: Icon(Icons.favorite, size: 18, color: shade.stamp),
                onPressed: () => audio.toggleLike(track),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsTab(
    BuildContext context,
    ThemeProvider theme,
    AudioPlaybackService audio,
    ShadeTokens shade,
  ) {
    if (_loadingPlaylists) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Loading playlists...',
            style: GoogleFonts.karla(color: shade.muted, fontSize: 12),
          ),
        ),
      );
    }

    if (_playlists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Text(
                'No playlists yet',
                style: GoogleFonts.fraunces(
                  color: shade.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create your first paper playlist to organize your listening sheets.',
                style: GoogleFonts.karla(color: shade.muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TactileButton(
                label: 'Create playlist',
                onPressed: () => _showCreatePlaylistDialog(context, shade),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _playlists.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, idx) {
        final pl = _playlists[idx];

        return PaperSheet(
          enableTilt: false,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SANTORI PLAYLIST',
                    style: GoogleFonts.karla(
                      color: shade.muted,
                      fontSize: 8.5,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 14,
                      color: shade.muted,
                    ),
                    onPressed: () async {
                      await ApiService.deletePlaylist(pl.id);
                      _fetchPlaylists();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pl.name,
                    style: GoogleFonts.fraunces(
                      color: shade.text,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pl.description.isNotEmpty
                        ? pl.description
                        : 'No description',
                    style: GoogleFonts.karla(color: shade.muted, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${pl.trackCount} tracks',
                    style: GoogleFonts.karla(color: shade.muted, fontSize: 10),
                  ),
                  if (pl.tracks.isNotEmpty)
                    TactileButton(
                      label: 'Play all',
                      icon: Icons.play_arrow,
                      onPressed: () =>
                          audio.playTrack(pl.tracks.first, newQueue: pl.tracks),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
