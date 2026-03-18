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
    return CryptoKline(
      timestamp: DateTime.fromMillisecondsSinceEpoch(arr[0] as int),
      open: (arr[1] as num).toDouble(),
      high: (arr[2] as num).toDouble(),
      low: (arr[3] as num).toDouble(),
      close: (arr[4] as num).toDouble(),
      volume: (arr[5] as num).toDouble(),
    );
  }
}
