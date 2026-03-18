import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/exchange_response.dart';

const _cacheTtlMinutes = 60;
const _fetchTimeoutSeconds = 10;
const _keyExchangeCache = 'exchange_rate_cache';
const _keyExchangeTimestamp = 'exchange_last_fetch_time';

class ExchangeRateService {
  ExchangeRateService(this._prefs);

  final SharedPreferencesAsync _prefs;

  String _buildApiUrl(String baseCurrency) {
    final key = dotenv.env['EXCHANGE_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw ExchangeRateException('API key not configured');
    }
    return 'https://v6.exchangerate-api.com/v6/$key/latest/$baseCurrency';
  }

  Future<bool> _isCacheValid() async {
    final timestampStr = await _prefs.getString(_keyExchangeTimestamp);
    if (timestampStr == null) return false;
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < (_cacheTtlMinutes * 60 * 1000);
  }

  Future<ExchangeResponse?> _getCachedResponse(String baseCurrency) async {
    if (!await _isCacheValid()) return null;
    final cached = await _prefs.getString('${_keyExchangeCache}_$baseCurrency');
    if (cached == null) return null;
    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      return ExchangeResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(
    String baseCurrency,
    ExchangeResponse response,
  ) async {
    final json = {
      'result': response.result,
      'base_code': response.baseCode,
      'conversion_rates': response.conversionRates,
    };
    await _prefs.setString(
      '${_keyExchangeCache}_$baseCurrency',
      jsonEncode(json),
    );
    await _prefs.setString(
      _keyExchangeTimestamp,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<ExchangeResponse> fetchRates(String baseCurrency) async {
    final cached = await _getCachedResponse(baseCurrency);
    if (cached != null) return cached;

    final uri = Uri.parse(_buildApiUrl(baseCurrency));

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: _fetchTimeoutSeconds));

      if (response.statusCode != 200) {
        throw ExchangeRateException(
          'Failed to fetch rates: ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final exchangeResponse = ExchangeResponse.fromJson(json);

      if (exchangeResponse.result != 'success') {
        throw ExchangeRateException(
          'API returned error: ${exchangeResponse.result}',
        );
      }

      await _saveToCache(baseCurrency, exchangeResponse);
      return exchangeResponse;
    } on TimeoutException {
      throw ExchangeRateException('Request timed out. Please try again.');
    } on SocketException {
      throw ExchangeRateException(
        'No network connection. Please check your internet.',
      );
    }
  }
}

class ExchangeRateException implements Exception {
  final String message;
  ExchangeRateException(this.message);

  @override
  String toString() => 'ExchangeRateException: $message';
}
