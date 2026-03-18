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

  Color _neonColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? accentColor : lightNumpadNeonColor;
  }

  Color _textColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  Color _fillColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.4);
  }

  @override
  Widget build(BuildContext context) {
    final neon = _neonColor(context);

    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _fillColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: neon, width: 1),
          boxShadow: [
            BoxShadow(
              color: neon.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: neon.withValues(alpha: 0.25),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isWide ? 14 : 22,
              fontWeight: FontWeight.w500,
              color: _textColor(context),
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
