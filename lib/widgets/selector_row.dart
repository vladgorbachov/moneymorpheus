import 'package:flutter/material.dart';

/// Tappable row for settings: label (hint) + value + arrow, right-aligned.
/// Matches the visual style of CurrencyRow on the main screen.
class SelectorRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isDarkMode;

  const SelectorRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.95)
        : const Color(0xFF1A1A2E);
    final hintColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                color: hintColor,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: hintColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
