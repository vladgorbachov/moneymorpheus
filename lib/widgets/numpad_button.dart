import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';

class NumpadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const NumpadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.black.withValues(alpha: 0.9);
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.05);

    final borderColor = isDark
        ? accentColor.withValues(alpha: 0.35)
        : lightAccentColor.withValues(alpha: 0.25);
    final glowShadows = isDark
        ? [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ]
        : <BoxShadow>[];

    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: glowShadows,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
