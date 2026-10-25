import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../services/audio_service.dart';
import '../../theme/theme_provider.dart';
import 'paper_sheet.dart';

class RuledNotebook extends StatelessWidget {
  final List<Track> tracks;

  const RuledNotebook({super.key, required this.tracks});

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
    final current = audio.currentTrack;

    return PaperSheet(
      tiltAngle: 0.5,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Ruled notebook background lines & red margin
          Positioned.fill(
            child: CustomPaint(
              painter: _NotebookLinesPainter(
                ruleColor: shade.rule.withValues(
                  alpha: shade.isDark ? 0.35 : 0.65,
                ),
                marginColor: const Color(0xFFDC2626).withValues(alpha: 0.35),
                lineSpacing: 34.0,
                marginOffset: 48.0,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(left: 42, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Up next',
                        style: GoogleFonts.fraunces(
                          color: shade.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${tracks.length} queued',
                        style: GoogleFonts.karla(
                          color: shade.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (tracks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 48,
                      top: 24,
                      bottom: 24,
                    ),
                    child: Text(
                      'Your notebook is empty. Search and tap play to queue tracks.',
                      style: GoogleFonts.karla(
                        color: shade.muted,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  ...List.generate(tracks.length.clamp(0, 7), (index) {
                    final track = tracks[index];
                    final isSelected = current?.id == track.id;

                    return SizedBox(
                      height: 34.0,
                      child: Row(
                        children: [
                          // Sequence Number
                          SizedBox(
                            width: 38,
                            child: Text(
                              '${index + 1}.',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.karla(
                                color: isSelected
                                    ? theme.inkColor
                                    : shade.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14), // margin gap
                          // Track Title & Artist
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (isSelected) {
                                  audio.togglePlay();
                                } else {
                                  audio.playTrack(track);
                                }
                              },
                              child: Row(
                                children: [
                                  if (isSelected && audio.isPlaying)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: theme.inkColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      track.title,
                                      style: GoogleFonts.karla(
                                        color: isSelected
                                            ? theme.inkColor
                                            : shade.text,
                                        fontSize: 12.5,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '— ${track.artist}',
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
                          ),

                          // Duration & Actions
                          Text(
                            _formatDuration(track.duration),
                            style: GoogleFonts.karla(
                              color: shade.muted,
                              fontSize: 10.5,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 13,
                              color: shade.muted,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            onPressed: () => audio.removeFromQueue(index),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  final Color ruleColor;
  final Color marginColor;
  final double lineSpacing;
  final double marginOffset;

  _NotebookLinesPainter({
    required this.ruleColor,
    required this.marginColor,
    required this.lineSpacing,
    required this.marginOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rulePaint = Paint()
      ..color = ruleColor
      ..strokeWidth = 0.8;

    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.4;

    // Horizontal notebook rules starting below header
    for (double y = 44.0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }

    // Vertical red margin line
    canvas.drawLine(
      Offset(marginOffset, 0),
      Offset(marginOffset, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NotebookLinesPainter oldDelegate) {
    return oldDelegate.ruleColor != ruleColor ||
        oldDelegate.marginColor != marginColor;
  }
}
