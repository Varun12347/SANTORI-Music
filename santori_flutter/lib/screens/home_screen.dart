import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../theme/paper_tokens.dart';
import '../theme/theme_provider.dart';
import '../widgets/paper/paper_sheet.dart';
import '../widgets/paper/polaroid_art.dart';
import '../widgets/paper/rubber_stamp.dart';
import '../widgets/paper/ruled_notebook.dart';
import '../widgets/paper/tactile_button.dart';
import '../widgets/visualizer/paper_visualizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Track> _shelfTracks = [];
  bool _loadingShelf = true;

  @override
  void initState() {
    super.initState();
    _fetchShelfTracks();
  }

  Future<void> _fetchShelfTracks() async {
    final tracks = await ApiService.getTrendingTracks(language: 'hindi');
    if (mounted) {
      setState(() {
        _shelfTracks = tracks;
        _loadingShelf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final audio = Provider.of<AudioPlaybackService>(context);
    final shade = theme.currentShade;
    final current = audio.currentTrack;
    final isLiked = current != null && audio.isLiked(current.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Top Banner Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: shade.paper2,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: shade.rule.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: theme.inkColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SANTORI: Real 320kbps audio streaming with Web Audio synthesizer fallback.',
                      style: GoogleFonts.karla(
                        color: shade.text,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'THEME: ${theme.currentShade.name.toUpperCase()}',
                    style: GoogleFonts.karla(
                      color: shade.muted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!ApiService.lastFetchSucceeded) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Backend server unreachable at ${ApiService.baseUrl}. Check laptop Wi-Fi.',
                        style: GoogleFonts.karla(
                          color: shade.text,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _loadingShelf = true);
                        _fetchShelfTracks();
                      },
                      child: Text(
                        'Retry',
                        style: GoogleFonts.karla(
                          color: theme.inkColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Top Row: Now Playing Sheet + Up Next Notebook
            if (isNarrow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNowPlayingSheet(
                    context,
                    theme,
                    audio,
                    shade,
                    current,
                    isLiked,
                  ),
                  const SizedBox(height: 18),
                  RuledNotebook(tracks: audio.queue),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildNowPlayingSheet(
                      context,
                      theme,
                      audio,
                      shade,
                      current,
                      isLiked,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: RuledNotebook(tracks: audio.queue)),
                ],
              ),

            const SizedBox(height: 28),

            // "On the shelf" Card Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'On the shelf',
                  style: GoogleFonts.fraunces(
                    color: shade.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Curated Selection',
                  style: GoogleFonts.karla(color: shade.muted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_loadingShelf)
              Container(
                height: 140,
                alignment: Alignment.center,
                child: Text(
                  'Fetching tracks from shelf...',
                  style: GoogleFonts.karla(color: shade.muted, fontSize: 12),
                ),
              )
            else
              _buildShelfGrid(
                context,
                theme,
                audio,
                shade,
                constraints.maxWidth,
              ),
          ],
        );
      },
    );
  }

  Widget _buildNowPlayingSheet(
    BuildContext context,
    ThemeProvider theme,
    AudioPlaybackService audio,
    ShadeTokens shade,
    Track? current,
    bool isLiked,
  ) {
    return PaperSheet(
      tiltAngle: -0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Now playing',
                style: GoogleFonts.fraunces(
                  color: shade.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLiked)
                const RubberStamp(label: 'LIKED')
              else
                Text(
                  'DESK AUDIO',
                  style: GoogleFonts.karla(
                    color: shade.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (current != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Polaroid Art with Tape
                PolaroidArt(
                  imageUrl: current.image,
                  title: current.title,
                  artist: current.artist,
                  size: 150,
                  tiltDegrees: -1.2,
                ),
                const SizedBox(width: 16),

                // Controls & Live Visualizer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.title,
                        style: GoogleFonts.fraunces(
                          color: shade.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        current.artist,
                        style: GoogleFonts.karla(
                          color: shade.muted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (current.album.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          current.album,
                          style: GoogleFonts.karla(
                            color: shade.muted.withValues(alpha: 0.8),
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Canvas Visualizer Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: shade.paper2.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: shade.rule.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'VISUALIZER: ${theme.visualizer.name.toUpperCase()}',
                                  style: GoogleFonts.karla(
                                    color: shade.muted,
                                    fontSize: 8.5,
                                  ),
                                ),
                                Text(
                                  audio.isPlaying ? 'ACTIVE' : 'IDLE',
                                  style: GoogleFonts.karla(
                                    color: shade.muted,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const PaperVisualizer(height: 42),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Play/Pause Action Button
                      Row(
                        children: [
                          TactileButton(
                            label: audio.isPlaying ? 'Pause' : 'Play',
                            icon: audio.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            onPressed: audio.togglePlay,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            current.isDemo
                                ? 'Generated Tone'
                                : '320kbps Stream',
                            style: GoogleFonts.karla(
                              color: shade.muted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No track currently selected.',
                  style: GoogleFonts.karla(color: shade.muted, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShelfGrid(
    BuildContext context,
    ThemeProvider theme,
    AudioPlaybackService audio,
    ShadeTokens shade,
    double maxWidth,
  ) {
    final int crossAxisCount = maxWidth > 1000 ? 5 : (maxWidth > 650 ? 4 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _shelfTracks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, idx) {
        final track = _shelfTracks[idx];
        final tiltAngle = idx % 2 == 0 ? -1.4 : 1.1;

        return PaperSheet(
          tiltAngle: tiltAngle,
          padding: const EdgeInsets.all(8),
          onTap: () => audio.playTrack(track, newQueue: _shelfTracks),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shade.desk,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: track.image.isNotEmpty
                      ? Image.network(
                          track.image,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Center(
                            child: Icon(Icons.music_note, color: shade.muted),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.music_note, color: shade.muted),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                track.title,
                style: GoogleFonts.fraunces(
                  color: shade.text,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                track.artist,
                style: GoogleFonts.karla(color: shade.muted, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
