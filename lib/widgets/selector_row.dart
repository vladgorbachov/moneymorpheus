import 'package:flutter/material.dart';

class SelectorRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isDarkMode;

  /// When true, row vertical padding is halved (compact second/third currency rows).
  final bool compactVertical;

  const SelectorRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.isDarkMode = true,
    this.compactVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.95)
        : const Color(0xFF1A1A2E);
    final hintColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.68)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.54);

    final vPad = compactVertical ? 7.0 : 14.0;
    final labelSize = compactVertical ? 21.0 : 23.0;
    final valueSize = compactVertical ? 25.0 : 27.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  color: hintColor,
                  height: compactVertical ? 1.05 : null,
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
                  fontSize: valueSize,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 25,
                color: hintColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
