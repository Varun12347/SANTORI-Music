import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';

class PaperSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double tiltAngle; // in degrees
  final bool enableTilt;
  final VoidCallback? onTap;

  const PaperSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
    this.tiltAngle = 0.0,
    this.enableTilt = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final shade = theme.currentShade;
    final isDark = shade.isDark;

    final angleInRadians = (enableTilt && theme.tilted)
        ? (tiltAngle * math.pi / 180)
        : 0.0;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: shade.paper,
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(
          color: shade.rule.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            offset: const Offset(0, 4),
            blurRadius: isDark ? 18 : 12,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    if (angleInRadians != 0.0) {
      return Transform.rotate(
        angle: angleInRadians,
        alignment: Alignment.center,
        child: content,
      );
    }

    return content;
  }
}
