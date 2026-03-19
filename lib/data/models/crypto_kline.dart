class CryptoKline {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const CryptoKline({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CryptoKline.fromBinanceArray(List<dynamic> arr) {
    if (arr.length < 6) {
      throw FormatException('Invalid kline array length: ${arr.length}');
    }
    final timestamp = int.tryParse(arr[0].toString()) ?? 0;
    final open = double.tryParse(arr[1].toString()) ?? 0.0;
    final high = double.tryParse(arr[2].toString()) ?? 0.0;
    final low = double.tryParse(arr[3].toString()) ?? 0.0;
    final close = double.tryParse(arr[4].toString()) ?? 0.0;
    final volume = double.tryParse(arr[5].toString()) ?? 0.0;

    return CryptoKline(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}
