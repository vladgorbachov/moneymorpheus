import 'package:flutter/material.dart';

class CurrencyRow extends StatelessWidget {
  final String currencyCode;
  final double amount;
  final VoidCallback? onTap;
  final bool isDarkMode;

  const CurrencyRow({
    super.key,
    required this.currencyCode,
    required this.amount,
    this.onTap,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = _formatAmount(amount);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  currencyCode,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hintColor,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: hintColor,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatted,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFF1A1A2E).withValues(alpha: 0.08),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value >= 1e9 || (value < 1e-2 && value > 0)) {
      return value.toStringAsExponential(2);
    }
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    final s = value.toStringAsFixed(8);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
