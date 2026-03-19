import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';

class NumpadButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback onTap;
  final bool compactTopRow;
  final bool glassHighlight;
  final double? fontSize;
  final FontWeight fontWeight;

  const NumpadButton({
    super.key,
    this.label,
    this.child,
    required this.onTap,
    this.compactTopRow = false,
    this.glassHighlight = false,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
  }) : assert(label != null || child != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.98)
        : Colors.black.withValues(alpha: 0.82);
    final effectiveFontSize = fontSize ?? (compactTopRow ? 26 : 34);

    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: glassButtonDecoration(
          isDarkMode: isDark,
          borderRadius: BorderRadius.circular(compactTopRow ? 18 : 22),
          highlight: glassHighlight,
        ),
        child: Center(
          child: child ??
              Text(
                label!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Merriweather',
                  fontSize: effectiveFontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                  letterSpacing: 0.6,
                ),
              ),
        ),
      ),
    );
  }
}
