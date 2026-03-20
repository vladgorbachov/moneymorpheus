import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';

/// Key coloring for flat reference-style numpad on gradient.
enum ConverterKeyTone {
  /// Digits and decimal (light: teal; dark: white).
  digit,

  /// AC clear (light: coral; dark: white).
  clear,

  /// Backspace, CRYPTO, etc. (light: teal; dark: white).
  auxiliary,
}

class NumpadButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback onTap;
  final bool compactTopRow;
  final bool glassHighlight;
  final double? fontSize;
  final FontWeight fontWeight;

  /// When true, no glass pill — text on gradient (main converter).
  final bool flatConverterStyle;

  /// Used when [flatConverterStyle] is true.
  final ConverterKeyTone converterTone;

  const NumpadButton({
    super.key,
    this.label,
    this.child,
    required this.onTap,
    this.compactTopRow = false,
    this.glassHighlight = false,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.flatConverterStyle = false,
    this.converterTone = ConverterKeyTone.digit,
  }) : assert(label != null || child != null);

  static const String _font = 'Roboto';

  Color _flatForeground(bool isDark) {
    if (isDark) return Colors.white;
    switch (converterTone) {
      case ConverterKeyTone.clear:
        return refLightKeypadCoral;
      case ConverterKeyTone.digit:
      case ConverterKeyTone.auxiliary:
        return refLightKeypadTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Main keypad digits: compact row uses explicit [fontSize].
    final effectiveFontSize = fontSize ?? (compactTopRow ? 25 : 35);

    if (flatConverterStyle) {
      return GestureDetector(
        onTapDown: (_) => HapticFeedback.lightImpact(),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: child ??
              Text(
                label!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: effectiveFontSize,
                  fontWeight: fontWeight,
                  color: _flatForeground(isDark),
                  letterSpacing: 0.3,
                ),
              ),
        ),
      );
    }

    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.98)
        : Colors.black.withValues(alpha: 0.82);

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
