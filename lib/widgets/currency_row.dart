import 'package:flutter/material.dart';

class CurrencyRow extends StatelessWidget {
  final String currencyCode;
  final double amount;
  final VoidCallback? onTap;
  final bool isDarkMode;
  final bool showDivider;

  const CurrencyRow({
    super.key,
    required this.currencyCode,
    required this.amount,
    this.onTap,
    this.isDarkMode = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = _formatAmount(amount);
    final textColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.95)
        : const Color(0xFF1A1A2E);
    final hintColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.66)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.58);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 122,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    currencyCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: 'DejaVuSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: hintColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 26,
                    color: hintColor,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                formatted,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.9,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (showDivider)
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
