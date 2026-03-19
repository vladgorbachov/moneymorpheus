class CryptoTicker {
  final String symbol;
  final double price;
  final double change24h;
  final double volume;
  final double high24h;
  final double low24h;
  final double quoteVolume24h;

  const CryptoTicker({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.volume,
    this.high24h = 0,
    this.low24h = 0,
    this.quoteVolume24h = 0,
  });

  String get baseSymbol => symbol.replaceAll('USDT', '');

  factory CryptoTicker.fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol'] as String? ?? '';
    final lastPrice = _parseDouble(json['lastPrice']);
    final priceChangePercent = _parseDouble(json['priceChangePercent']);
    final volume = _parseDouble(json['volume']);
    final high24h = _parseDouble(json['highPrice']);
    final low24h = _parseDouble(json['lowPrice']);
    final quoteVolume24h = _parseDouble(json['quoteVolume']);

    return CryptoTicker(
      symbol: symbol,
      price: lastPrice,
      change24h: priceChangePercent,
      volume: volume,
      high24h: high24h,
      low24h: low24h,
      quoteVolume24h: quoteVolume24h,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
