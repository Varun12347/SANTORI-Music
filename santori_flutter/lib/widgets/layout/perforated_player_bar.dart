import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/audio_service.dart';
import '../../theme/theme_provider.dart';
import '../paper/tactile_button.dart';

class PerforatedPlayerBar extends StatelessWidget {
  const PerforatedPlayerBar({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s < 10 ? '0' : ''}$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final audio = Provider.of<AudioPlaybackService>(context);
    final shade = theme.currentShade;
    final track = audio.currentTrack;
    final isLiked = track != null && audio.isLiked(track.id);

    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: shade.paper,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shade.isDark ? 0.45 : 0.10),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dashed Perforation Line at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 2),
              painter: _DashedLinePainter(color: shade.rule),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Track Info (Left)
                Expanded(
                  flex: 3,
                  child: track != null
                      ? Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: shade.desk,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: (track.image.isNotEmpty)
                                  ? Image.network(
                                      track.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(
                                          'SANTORI',
                                          style: GoogleFonts.karla(
                                            color: shade.muted,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'SANTORI',
                                        style: GoogleFonts.karla(
                                          color: shade.muted,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: GoogleFonts.fraunces(
                                      color: shade.text,
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
                                  if (track.isDemo)
                                    Text(
                                      'Demo Tone',
                                      style: GoogleFonts.karla(
                                        color: shade.muted.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 9,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: isLiked ? shade.stamp : shade.muted,
                              ),
                              onPressed: () => audio.toggleLike(track),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        )
                      : Text(
                          'No track loaded',
                          style: GoogleFonts.karla(
                            color: shade.muted,
                            fontSize: 11,
                          ),
                        ),
                ),

                // Controls & Seek Bar (Center)
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              size: 16,
                              color: audio.shuffle
                                  ? theme.inkColor
                                  : shade.muted,
                            ),
                            onPressed: audio.toggleShuffle,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                              size: 20,
                              color: shade.text,
                            ),
                            onPressed: audio.prevTrack,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          TactileButton(
                            isRound: true,
                            size: 34,
                            onPressed: audio.togglePlay,
                            child: Icon(
                              audio.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: shade.paper,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              size: 20,
                              color: shade.text,
                            ),
                            onPressed: audio.nextTrack,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              audio.repeat == SantoriRepeatMode.one
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                              size: 16,
                              color: audio.repeat != SantoriRepeatMode.off
                                  ? theme.inkColor
                                  : shade.muted,
                            ),
                            onPressed: audio.toggleRepeat,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),

                      // Real Scrub Seek Bar
                      Row(
                        children: [
                          Text(
                            _formatDuration(audio.currentPosition),
                            style: GoogleFonts.karla(
                              color: shade.muted,
                              fontSize: 9.5,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2.0,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 4.5,
                                ),
                                activeTrackColor: theme.inkColor,
                                inactiveTrackColor: shade.rule.withValues(
                                  alpha: 0.5,
                                ),
                                thumbColor: theme.inkColor,
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                min: 0.0,
                                max: audio.totalDuration.inSeconds > 0
                                    ? audio.totalDuration.inSeconds.toDouble()
                                    : 100.0,
                                value: audio.currentPosition.inSeconds
                                    .toDouble()
                                    .clamp(
                                      0.0,
                                      audio.totalDuration.inSeconds > 0
                                          ? audio.totalDuration.inSeconds
                                                .toDouble()
                                          : 100.0,
                                    ),
                                onChanged: (val) {
                                  audio.seek(Duration(seconds: val.toInt()));
                                },
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(audio.totalDuration),
                            style: GoogleFonts.karla(
                              color: shade.muted,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Volume & Sleep Timer (Right)
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (theme.sleepRemainingSeconds != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: shade.paper2,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: shade.rule, width: 0.7),
                            ),
                            child: Text(
                              '${(theme.sleepRemainingSeconds! / 60).ceil()}m',
                              style: GoogleFonts.karla(
                                color: theme.inkColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Icon(
                        audio.volume == 0 ? Icons.volume_off : Icons.volume_up,
                        size: 16,
                        color: shade.muted,
                      ),
                      SizedBox(
                        width: 70,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 3.5,
                            ),
                            activeTrackColor: theme.inkColor,
                            inactiveTrackColor: shade.rule.withValues(
                              alpha: 0.5,
                            ),
                            thumbColor: theme.inkColor,
                            overlayShape: SliderComponentShape.noOverlay,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: 1.0,
                            value: audio.volume,
                            onChanged: (v) => audio.setVolume(v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
