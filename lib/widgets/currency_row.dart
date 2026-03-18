import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'glass_card.dart';

class CurrencyRow extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = _formatAmount(amount);
    final textColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.85);

    final content = GlassCard(
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            currencyCode,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
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
