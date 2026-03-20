import 'package:flutter/material.dart';

import '../crypto_logos.dart';
import 'asset_metadata.dart';

/// Crypto asset metadata: symbol, displayName, logoUrl with fallback.
class CryptoAssetMetadata extends AssetMetadata {
  @override
  final String id;

  final String displayName;

  final String? logoUrl;

  const CryptoAssetMetadata({
    required this.id,
    required this.displayName,
    this.logoUrl,
  });

  @override
  String get displayLabel => displayName;

  @override
  String? get displaySubtitle => id != displayName ? '${id}USDT' : null;

  @override
  Widget? get leadingWidget => _CryptoLogoWidget(
        symbol: id,
        url: logoUrl ?? cryptoLogoUrl(id),
      );

  static CryptoAssetMetadata fromSymbol(String symbol) =>
      CryptoAssetMetadata(
        id: symbol,
        displayName: cryptoDisplayName(symbol),
        logoUrl: cryptoLogoUrl(symbol),
      );
}

class _CryptoLogoWidget extends StatelessWidget {
  final String symbol;
  final String url;

  const _CryptoLogoWidget({required this.symbol, required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _Fallback(symbol: symbol),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String symbol;

  const _Fallback({required this.symbol});

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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
