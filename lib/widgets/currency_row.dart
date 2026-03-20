import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';

/// Teal / white on gradient; amounts use LARAZ and scale down when long.
class CurrencyRow extends StatelessWidget {
  final String currencyCode;
  final double amount;

  /// When set (base row), shows raw keypad input; [amount] still drives conversion.
  final String? inputOverride;
  final VoidCallback? onTap;

  const CurrencyRow({
    super.key,
    required this.currencyCode,
    required this.amount,
    this.inputOverride,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = inputOverride != null
        ? _formatInputDisplay(inputOverride!)
        : _formatAmount(context, amount);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : refLightKeypadTeal;
    final lineColor = primaryText;
    final scale = _scaleForDisplayLength(formatted.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 120.0;
        final codeSize = ((h * 0.16).clamp(15.0, 20.0) + 1) * 1.5;
        final baseAmountSize =
            (((h * 0.36).clamp(26.0, 48.0) + 3) * 1.5) * 0.7;
        final amountSize = baseAmountSize * scale;
        final iconSize = codeSize * 1.15;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 2, 4),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currencyCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kLarazFontFamily,
                          fontSize: codeSize,
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (onTap != null) ...[
                        SizedBox(width: codeSize * 0.15),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: iconSize,
                          color: primaryText,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              formatted,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: kLarazFontFamily,
                                fontSize: amountSize,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                                height: 1.05,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: (h * 0.06).clamp(4.0, 10.0)),
                        Container(height: 1, color: lineColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Smaller text when digit count grows (default `0.0` uses full [base] scale).
  static double _scaleForDisplayLength(int len) {
    if (len <= 4) return 1.0;
    if (len <= 8) return 0.88;
    if (len <= 12) return 0.76;
    if (len <= 16) return 0.64;
    if (len <= 20) return 0.54;
    return 0.44;
  }

  String _formatInputDisplay(String raw) {
    if (raw == '0') return '0.0';
    return raw;
  }

  String _formatAmount(BuildContext context, double value) {
    if (value.isNaN || value.isInfinite) return '—';
    if (value == 0) return '0.0';
    final capped = value.abs() > kMaxConverterAmount
        ? value.sign * kMaxConverterAmount
        : value;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    if (capped != 0 && capped.abs() < 1e-8) {
      return capped.toStringAsExponential(4);
    }
    if (capped.abs() >= 1e9) {
      return capped.toStringAsExponential(4);
    }
    final nf = NumberFormat.decimalPatternDigits(
      locale: localeTag,
      decimalDigits: 8,
    );
    return nf.format(capped);
  }
}
