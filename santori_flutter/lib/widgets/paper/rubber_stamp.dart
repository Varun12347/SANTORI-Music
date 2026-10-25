import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';

class RubberStamp extends StatelessWidget {
  final String label;

  const RubberStamp({super.key, this.label = 'LIKED'});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final stampColor = theme.currentShade.stamp;

    return Transform.rotate(
      angle: -7 * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: stampColor, width: 1.8),
        ),
        child: Text(
          label,
          style: GoogleFonts.fraunces(
            color: stampColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
