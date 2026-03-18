import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import 'glass_card.dart';

class CurrencyRow extends ConsumerWidget {
  final String currencyCode;
  final double amount;

  const CurrencyRow({
    super.key,
    required this.currencyCode,
    required this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = _formatAmount(amount);

    return GlassCard(
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
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
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
