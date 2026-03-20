import 'package:flutter/material.dart';

// Reference converter UI (light): teal top → mint / light green bottom (~2 tones darker vs prior).
const Color refLightGradientTop = Color(0xFF1BA8BE);
const Color refLightGradientMid = Color(0xFFA8D8C8);
const Color refLightGradientBottom = Color(0xFFD0E4D4);

/// Light numpad: two tones darker than reference teal/coral for readability.
const Color refLightKeypadTeal = Color(0xFF006978);
const Color refLightKeypadCoral = Color(0xFFD84315);

// Reference converter UI (dark): deep indigo → magenta
const Color refDarkGradientTop = Color(0xFF1E0F3D);
const Color refDarkGradientBottom = Color(0xFFC2185B);

// Legacy (theme surfaces, glass accents)
const Color darkBackgroundColor = Color(0xFF0D0524);
const Color accentColor = Color(0xFF9568C9);
const Color darkAccentColor = Color(0xFF9568C9);
const Color lightBackgroundColor = Color(0xFFF1F8F7);
const Color lightAccentColor = Color(0xFF49B8A5);

/// Main converter + crypto list/detail: full-screen vertical gradient (no wallpaper).
BoxDecoration converterScreenDecoration(bool isDarkMode) {
  if (isDarkMode) {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [refDarkGradientTop, refDarkGradientBottom],
      ),
    );
  }
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        refLightGradientTop,
        refLightGradientMid,
        refLightGradientBottom,
      ],
      stops: [0.0, 0.45, 1.0],
    ),
  );
}

BoxDecoration glassButtonDecoration({
  required bool isDarkMode,
  BorderRadius? borderRadius,
  bool highlight = false,
}) {
  final accent = isDarkMode ? accentColor : lightAccentColor;
  return BoxDecoration(
    borderRadius: borderRadius ?? BorderRadius.circular(18),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: isDarkMode ? 0.18 : 0.30),
        Colors.white.withValues(alpha: isDarkMode ? 0.05 : 0.12),
      ],
    ),
    border: Border.all(
      color: Colors.white.withValues(alpha: isDarkMode ? 0.38 : 0.52),
      width: 1.1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withValues(alpha: isDarkMode ? 0.18 : 0.24),
        blurRadius: 14,
        offset: const Offset(-2, -2),
      ),
      BoxShadow(
        color: accent.withValues(
          alpha: highlight
              ? (isDarkMode ? 0.22 : 0.16)
              : (isDarkMode ? 0.14 : 0.08),
        ),
        blurRadius: highlight ? 18 : 12,
        spreadRadius: highlight ? 1.5 : 0.2,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDarkMode ? 0.26 : 0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

// Unused, kept for compatibility
const Color lightNumpadNeonColor = Color(0xFF707070);
