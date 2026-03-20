import 'package:flutter/material.dart';

/// Typography for reference-style converter rows (Roboto / system sans).
const String _kConverterSans = 'Roboto';

/// Teal / white on gradient per reference mockups.
class CurrencyRow extends StatelessWidget {
  final String currencyCode;
  final double amount;
  final VoidCallback? onTap;

  const CurrencyRow({
    super.key,
    required this.currencyCode,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = _formatAmount(amount);
    const lineColor = Colors.white;
    const primaryText = Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 120.0;
        final codeSize = (h * 0.16).clamp(15.0, 20.0) + 1;
        // Amount column: +2 vs previous sizing (both themes).
        final amountSize = (h * 0.36).clamp(26.0, 48.0) + 3;
        final iconSize = codeSize * 1.15;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                          fontFamily: _kConverterSans,
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
                  const Spacer(),
                  IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatted,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: _kConverterSans,
                              fontSize: amountSize,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                              height: 1.05,
                              letterSpacing: -0.5,
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
