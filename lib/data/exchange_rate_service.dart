import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import 'models/exchange_response.dart';

class ExchangeRateService {
  ExchangeResponse? _cachedResponse;
  String? _cachedBaseCurrency;

  Future<ExchangeResponse> fetchRates(String baseCurrency) async {
    if (_cachedResponse != null && _cachedBaseCurrency == baseCurrency) {
      return _cachedResponse!;
    }

    final uri = Uri.parse('$apiBaseUrl/latest/$baseCurrency');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw ExchangeRateException(
        'Failed to fetch rates: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final exchangeResponse = ExchangeResponse.fromJson(json);

    if (exchangeResponse.result != 'success') {
      throw ExchangeRateException('API returned error: ${exchangeResponse.result}');
    }

    _cachedResponse = exchangeResponse;
    _cachedBaseCurrency = baseCurrency;
    return exchangeResponse;
  }

  void clearCache() {
    _cachedResponse = null;
    _cachedBaseCurrency = null;
  }
}

class ExchangeRateException implements Exception {
  final String message;
  ExchangeRateException(this.message);

  @override
  String toString() => 'ExchangeRateException: $message';
}
