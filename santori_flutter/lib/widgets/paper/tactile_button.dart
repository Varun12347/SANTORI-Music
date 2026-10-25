import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';

class TactileButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final bool isRound;
  final double? size;

  const TactileButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.isRound = false,
    this.size,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final inkColor = theme.inkColor;
    final paperColor = theme.currentShade.paper;
    final shadowColor = theme.currentShade.inkShadow;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: Offset(0, _isPressed ? 2.0 : 0.0),
        child: Container(
          width: widget.size,
          height: widget.size,
          padding: widget.size != null ? EdgeInsets.zero : widget.padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: inkColor,
            borderRadius: widget.isRound
                ? BorderRadius.circular(999)
                : BorderRadius.circular(4.0),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child:
              widget.child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 14, color: paperColor),
                    if (widget.label != null) const SizedBox(width: 6),
                  ],
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: GoogleFonts.karla(
                        color: paperColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
