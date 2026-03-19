import 'package:flutter/material.dart';

import '../core/crypto_logos.dart';

/// Displays crypto logo with fallback to first-letter placeholder.
class CryptoLogo extends StatelessWidget {
  final String symbol;
  final double size;

  const CryptoLogo({super.key, required this.symbol, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.network(
          cryptoLogoUrl(symbol),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _FallbackLogo(symbol: symbol, size: size),
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final String symbol;
  final double size;

  const _FallbackLogo({required this.symbol, required this.size});

  @override
  Widget build(BuildContext context) {
    final letter = symbol.isNotEmpty ? symbol[0].toUpperCase() : '?';
    final hue = letter.codeUnitAt(0) % 360.0;
    final color = HSLColor.fromAHSL(1, hue, 0.5, 0.45).toColor();

    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
