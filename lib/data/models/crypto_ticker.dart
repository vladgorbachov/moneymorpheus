class CryptoTicker {
  final String symbol;
  final double price;
  final double change24h;
  final double volume;

  const CryptoTicker({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.volume,
  });

  String get baseSymbol => symbol.replaceAll('USDT', '');

  factory CryptoTicker.fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol'] as String? ?? '';
    final lastPrice = _parseDouble(json['lastPrice']);
    final priceChangePercent = _parseDouble(json['priceChangePercent']);
    final volume = _parseDouble(json['volume']);

    return CryptoTicker(
      symbol: symbol,
      price: lastPrice,
      change24h: priceChangePercent,
      volume: volume,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
