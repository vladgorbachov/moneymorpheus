import 'package:flutter/material.dart';

// Dark theme
const Color darkBackgroundColor = Color(0xFF0D0524);
const Color darkSphereColor1 = Color(0xFF3C1A65);
const Color darkSphereColor2 = Color(0xFF25113D);
const Color accentColor = Color(0xFF9568C9);
const Color darkAccentColor = Color(0xFF9568C9);

// Light theme
const Color lightBackgroundColor = Color(0xFFF1F8F7);
const Color lightSphereColor1 = Color(0xFFA0E3D5);
const Color lightSphereColor2 = Color(0xFFC6F1E5);
const Color lightAccentColor = Color(0xFF49B8A5);

// Gradients for main screen
const Color darkGradientStart = Color(0xFF9568C9);
const Color darkGradientEnd = Color(0xFF0D0524);
const Color lightGradientStart = Color(0xFF49B8A5);
const Color lightGradientEnd = Color(0xFFF1F8F7);

const String lightWallpaperAsset = 'assets/pictures/light_wallpaper.jpg';
const String darkWallpaperAsset = 'assets/pictures/dark_wallpaper.jpg';

String themedWallpaperAsset(bool isDarkMode) =>
    isDarkMode ? darkWallpaperAsset : lightWallpaperAsset;

Decoration buildThemedWallpaper(bool isDarkMode) {
  final overlay = isDarkMode
      ? [darkGradientStart.withValues(alpha: 0.68), darkGradientEnd.withValues(alpha: 0.88)]
      : [lightGradientStart.withValues(alpha: 0.32), lightGradientEnd.withValues(alpha: 0.72)];

  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage(themedWallpaperAsset(isDarkMode)),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        isDarkMode
            ? Colors.black.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.06),
        BlendMode.srcATop,
      ),
    ),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: overlay,
    ),
  );
}

BoxDecoration glassButtonDecoration({required bool isDarkMode, BorderRadius? borderRadius, bool highlight = false}) {
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
        color: accent.withValues(alpha: highlight ? (isDarkMode ? 0.22 : 0.16) : (isDarkMode ? 0.14 : 0.08)),
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
