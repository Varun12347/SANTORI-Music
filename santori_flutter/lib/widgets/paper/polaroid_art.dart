import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/paper_tokens.dart';
import '../../theme/theme_provider.dart';

class PolaroidArt extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String artist;
  final double size;
  final double tiltDegrees;

  const PolaroidArt({
    super.key,
    this.imageUrl,
    required this.title,
    required this.artist,
    this.size = 200,
    this.tiltDegrees = -1.2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final shade = theme.currentShade;
    final isDark = shade.isDark;

    final angleInRadians = theme.tilted ? (tiltDegrees * math.pi / 180) : 0.0;

    return Transform.rotate(
      angle: angleInRadians,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Polaroid Sheet
          Container(
            width: size,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
            decoration: BoxDecoration(
              color: shade.paper2,
              borderRadius: BorderRadius.circular(2.0),
              border: Border.all(
                color: shade.rule.withValues(alpha: isDark ? 0.3 : 0.5),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Square Image
                Container(
                  width: size - 20,
                  height: size - 20,
                  decoration: BoxDecoration(
                    color: shade.desk,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              _buildPlaceholder(shade),
                        )
                      : _buildPlaceholder(shade),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.fraunces(
                    color: shade.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  style: GoogleFonts.karla(color: shade.muted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Semi-transparent Tape Strip on Top
          Positioned(
            top: -10,
            child: Transform.rotate(
              angle: -1.5 * math.pi / 180,
              child: Container(
                width: 72,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : const Color(0xFFE2E2DC).withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(1.0),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFFB8B8B0).withValues(alpha: 0.40),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ShadeTokens shade) {
    return Container(
      color: shade.desk,
      alignment: Alignment.center,
      child: Text(
        'SANTORI',
        style: GoogleFonts.karla(
          color: shade.muted,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
