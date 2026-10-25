import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/paper/paper_sheet.dart';
import '../widgets/paper/tactile_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _genreChips = [
    'All genres',
    'Hindi',
    'Punjabi',
    'English',
    'Lofi',
    'Acoustic',
    'Indie',
    'Pop',
  ];

  String _selectedGenre = 'All genres';
  String _sortBy = 'default';
  List<Track> _results = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _triggerSearch('Top Hits');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      final q = query.trim().isNotEmpty
          ? query.trim()
          : (_selectedGenre != 'All genres' ? _selectedGenre : 'Top Hits');
      _triggerSearch(q);
    });
  }

  Future<void> _triggerSearch(String query) async {
    setState(() => _isLoading = true);
    final list = await ApiService.searchTracks(query, limit: 24);
    if (mounted) {
      setState(() {
        _results = list;
        _isLoading = false;
      });
    }
  }

  List<Track> _getSortedResults() {
    final list = List<Track>.from(_results);
    switch (_sortBy) {
      case 'title':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'artist':
        list.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'length':
        list.sort((a, b) => a.duration.compareTo(b.duration));
        break;
    }
    return list;
  }

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s < 10 ? '0' : ''}$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final audio = Provider.of<AudioPlaybackService>(context);
    final shade = theme.currentShade;
    final sorted = _getSortedResults();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        // Title
        Text(
          'Search music',
          style: GoogleFonts.fraunces(
            color: shade.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Search Bar & Sort Dropdown
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.karla(color: shade.text, fontSize: 13),
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by title, artist, album...',
                  hintStyle: GoogleFonts.karla(
                    color: shade.muted,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search, size: 18, color: shade.muted),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 16, color: shade.muted),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: shade.paper,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: shade.rule),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: shade.paper,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: shade.rule),
              ),
              child: DropdownButton<String>(
                value: _sortBy,
                underline: const SizedBox(),
                dropdownColor: shade.paper,
                style: GoogleFonts.karla(color: shade.text, fontSize: 12),
                items: const [
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                  DropdownMenuItem(value: 'title', child: Text('Title (A-Z)')),
                  DropdownMenuItem(value: 'artist', child: Text('Artist')),
                  DropdownMenuItem(value: 'length', child: Text('Length')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _sortBy = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Genre Filter Chips
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _genreChips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final genre = _genreChips[idx];
              final isSelected = _selectedGenre == genre;

              return InkWell(
                onTap: () {
                  setState(() => _selectedGenre = genre);
                  if (genre != 'All genres') {
                    _searchCtrl.clear();
                    _triggerSearch(genre);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.inkColor : shade.paper2,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isSelected
                          ? theme.inkColor
                          : shade.rule.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    genre,
                    style: GoogleFonts.karla(
                      color: isSelected ? shade.paper : shade.text,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Results Grid
        if (_isLoading)
          Container(
            height: 160,
            alignment: Alignment.center,
            child: Text(
              'Searching paper archives and JioSaavn library...',
              style: GoogleFonts.karla(color: shade.muted, fontSize: 12),
            ),
          )
        else if (sorted.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!ApiService.lastFetchSucceeded) ...[
                    Icon(Icons.cloud_off, size: 40, color: shade.muted),
                    const SizedBox(height: 12),
                    Text(
                      'Cannot reach backend server',
                      style: GoogleFonts.fraunces(
                        color: shade.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Attempted URL: ${ApiService.baseUrl}\nEnsure the FastAPI server is running on your laptop and your phone is connected to the same Wi-Fi.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.karla(color: shade.muted, fontSize: 11.5),
                    ),
                    const SizedBox(height: 16),
                    TactileButton(
                      label: 'Retry search',
                      icon: Icons.refresh,
                      onPressed: () => _triggerSearch(
                        _searchCtrl.text.isNotEmpty ? _searchCtrl.text : 'Top Hits',
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Nothing found. Try searching for Arijit Singh, Diljit, or Taylor Swift.',
                      style: GoogleFonts.karla(color: shade.muted, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : (constraints.maxWidth > 550 ? 2 : 1);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sorted.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: crossAxisCount == 1 ? 4.5 : 3.8,
                ),
                itemBuilder: (context, idx) {
                  final track = sorted[idx];
                  final isCurrent = audio.currentTrack?.id == track.id;
                  final isLiked = audio.isLiked(track.id);

                  return PaperSheet(
                    enableTilt: false,
                    padding: const EdgeInsets.all(8),
                    onTap: () => audio.playTrack(track, newQueue: sorted),
                    child: Row(
                      children: [
                        // Thumbnail
                        Container(
                          width: 44,
                          height: 44,
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
                                    child: Icon(
                                      Icons.music_note,
                                      color: shade.muted,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.music_note,
                                    color: shade.muted,
                                    size: 18,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),

                        // Title, Artist, Duration
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                track.title,
                                style: GoogleFonts.fraunces(
                                  color: isCurrent
                                      ? theme.inkColor
                                      : shade.text,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                track.artist,
                                style: GoogleFonts.karla(
                                  color: shade.muted,
                                  fontSize: 10.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _formatDuration(track.duration),
                                style: GoogleFonts.karla(
                                  color: shade.muted.withValues(alpha: 0.8),
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add to Queue & Like
                        IconButton(
                          icon: Icon(
                            Icons.playlist_add,
                            size: 18,
                            color: shade.muted,
                          ),
                          onPressed: () => audio.addToQueue(track),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          tooltip: 'Add to queue',
                        ),
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isLiked ? shade.stamp : shade.muted,
                          ),
                          onPressed: () => audio.toggleLike(track),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          tooltip: 'Like',
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
