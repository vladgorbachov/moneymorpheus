import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
