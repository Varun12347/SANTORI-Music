import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/audio_service.dart';
import '../../theme/paper_tokens.dart';
import '../../theme/theme_provider.dart';

class PaperVisualizer extends StatefulWidget {
  final double width;
  final double height;

  const PaperVisualizer({
    super.key,
    this.width = double.infinity,
    this.height = 54.0,
  });

  @override
  State<PaperVisualizer> createState() => _PaperVisualizerState();
}

class _PaperVisualizerState extends State<PaperVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final audio = Provider.of<AudioPlaybackService>(context);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _VisualizerPainter(
            time: _animController.value * 2 * math.pi,
            style: theme.visualizer,
            inkColor: theme.inkColor,
            isPlaying: audio.isPlaying,
          ),
        );
      },
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  final double time;
  final VisualizerStyle style;
  final Color inkColor;
  final bool isPlaying;

  _VisualizerPainter({
    required this.time,
    required this.style,
    required this.inkColor,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = inkColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;

    switch (style) {
      case VisualizerStyle.pencil:
        _drawPencil(canvas, size, strokePaint);
        break;
      case VisualizerStyle.ink:
        _drawInkWave(canvas, size, strokePaint);
        break;
      case VisualizerStyle.rings:
        _drawRings(canvas, size, strokePaint);
        break;
      case VisualizerStyle.bars:
        _drawBars(canvas, size, fillPaint);
        break;
    }
  }

  void _drawPencil(Canvas canvas, Size size, Paint paint) {
    const double barWidth = 3.0;
    const double gap = 4.0;
    final int totalBars = (size.width / (barWidth + gap)).floor();

    for (int i = 0; i < totalBars; i++) {
      double amplitude;

      if (isPlaying) {
        amplitude =
            0.2 +
            0.6 *
                math.sin(time * 3 + i * 0.4).abs() *
                (0.5 + 0.5 * math.sin(i * 1.2).abs());
      } else {
        amplitude = 0.15 + 0.08 * math.sin(time + i * 0.3);
      }

      final double barHeight = math.max(4.0, amplitude * size.height * 0.85);
      final double x = i * (barWidth + gap) + 2.0;
      final double y1 = (size.height - barHeight) / 2;
      final double y2 = y1 + barHeight;

      final double jitter = isPlaying ? (math.sin(time * 7 + i) * 0.8) : 0.0;
      canvas.drawLine(Offset(x + jitter, y1), Offset(x - jitter, y2), paint);
    }
  }

  void _drawInkWave(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    const int points = 48;
    final double sliceWidth = size.width / points;

    for (int i = 0; i <= points; i++) {
      final double x = i * sliceWidth;
      double y;

      if (isPlaying) {
        final wave1 = math.sin(time * 2.5 + i * 0.3) * (size.height * 0.3);
        final wave2 = math.cos(time * 1.5 + i * 0.15) * (size.height * 0.15);
        y = (size.height / 2) + wave1 + wave2;
      } else {
        y = (size.height / 2) + math.sin(time + i * 0.15) * 4.0;
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawRings(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = math.min(center.dx, center.dy) * 0.85;
    const int ringCount = 3;

    for (int r = 1; r <= ringCount; r++) {
      final double baseRadius = (r / ringCount) * maxRadius;
      final path = Path();
      const int steps = 24;

      for (int s = 0; s <= steps; s++) {
        final double angle = (s / steps) * 2 * math.pi;
        double wobble = 0.0;
        if (isPlaying) {
          wobble = math.sin(time * 3 + angle * 4 + r) * 3.5;
        } else {
          wobble = math.sin(time + angle * 2) * 1.5;
        }
        final double radius = baseRadius + wobble;
        final double px = center.dx + radius * math.cos(angle);
        final double py = center.dy + radius * math.sin(angle);

        if (s == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawBars(Canvas canvas, Size size, Paint paint) {
    const double barWidth = 4.0;
    const double gap = 3.0;
    final int count = (size.width / (barWidth + gap)).floor();

    for (int i = 0; i < count; i++) {
      double amp = isPlaying
          ? (0.15 + 0.7 * math.sin(time * 2 + i * 0.3).abs())
          : 0.1;
      final double h = math.max(3.0, amp * size.height);
      final double x = i * (barWidth + gap);
      final double y = size.height - h;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, h),
          const Radius.circular(1.0),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.style != style ||
        oldDelegate.inkColor != inkColor;
  }
}
