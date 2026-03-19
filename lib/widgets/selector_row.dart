import 'package:flutter/material.dart';

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
        ? Colors.white.withValues(alpha: 0.68)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.54);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: hintColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
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
