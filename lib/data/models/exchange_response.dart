class ExchangeResponse {
  final String result;
  final String baseCode;
  final Map<String, double> conversionRates;

  const ExchangeResponse({
    required this.result,
    required this.baseCode,
    required this.conversionRates,
  });

  factory ExchangeResponse.fromJson(Map<String, dynamic> json) {
    final rates = json['conversion_rates'] as Map<String, dynamic>?;
    final conversionRates = <String, double>{};
    if (rates != null) {
      for (final entry in rates.entries) {
        final value = entry.value;
        if (value is num) {
          conversionRates[entry.key] = value.toDouble();
        }
      }
    }
    return ExchangeResponse(
      result: json['result'] as String? ?? 'error',
      baseCode: json['base_code'] as String? ?? '',
      conversionRates: conversionRates,
    );
  }
}
