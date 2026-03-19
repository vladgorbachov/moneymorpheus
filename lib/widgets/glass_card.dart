import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isDarkMode;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final fillColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.25);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
