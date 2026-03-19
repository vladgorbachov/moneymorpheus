import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/crypto_kline.dart';
import '../models/crypto_ticker.dart';

const _tickerUrl = 'https://api.binance.com/api/v3/ticker/24hr';
const _klinesUrl = 'https://api.binance.com/api/v3/klines';
const _tickerCacheTtlSeconds = 60;
const _keyTickerCache = 'binance_ticker_cache';
const _keyTickerTimestamp = 'binance_ticker_timestamp';

class BinanceApiService {
  BinanceApiService(this._prefs);

  final SharedPreferencesAsync _prefs;

  List<CryptoTicker>? _inMemoryTickers;
  int? _inMemoryTimestamp;

  bool _isTickerCacheValid() {
    if (_inMemoryTimestamp == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (now - _inMemoryTimestamp!) < _tickerCacheTtlSeconds;
  }

  Future<List<CryptoTicker>> _getCachedTickers() async {
    if (_isTickerCacheValid() && _inMemoryTickers != null) {
      return _inMemoryTickers!;
    }
    final timestampStr = await _prefs.getString(_keyTickerTimestamp);
    if (timestampStr == null) return [];
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return [];
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((now - timestamp) >= _tickerCacheTtlSeconds) return [];

    final cached = await _prefs.getString(_keyTickerCache);
    if (cached == null) return [];
    try {
      final list = jsonDecode(cached) as List<dynamic>;
      final tickers = list
          .map((e) => CryptoTicker.fromJson(e as Map<String, dynamic>))
          .toList();
      _inMemoryTickers = tickers;
      _inMemoryTimestamp = timestamp;
      return tickers;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveTickersToCache(List<CryptoTicker> tickers) async {
    final list = tickers
        .map(
          (t) => {
            'symbol': t.symbol,
            'lastPrice': t.price.toString(),
            'priceChangePercent': t.change24h.toString(),
            'volume': t.volume.toString(),
            'highPrice': t.high24h.toString(),
            'lowPrice': t.low24h.toString(),
            'quoteVolume': t.quoteVolume24h.toString(),
          },
        )
        .toList();
    await _prefs.setString(_keyTickerCache, jsonEncode(list));
    await _prefs.setString(
      _keyTickerTimestamp,
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    );
    _inMemoryTickers = tickers;
    _inMemoryTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  Future<List<CryptoTicker>> fetchTickers() async {
    final cached = await _getCachedTickers();
    if (cached.isNotEmpty) return cached;

    final response = await http.get(Uri.parse(_tickerUrl));

    if (response.statusCode != 200) {
      throw BinanceApiException(
        'Failed to fetch tickers: ${response.statusCode}',
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final tickers = <CryptoTicker>[];

    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final symbol = map['symbol'] as String? ?? '';
      if (symbol.endsWith('USDT')) {
        tickers.add(CryptoTicker.fromJson(map));
      }
    }

    tickers.sort((a, b) => a.symbol.compareTo(b.symbol));
    await _saveTickersToCache(tickers);
    return tickers;
  }

  Future<List<CryptoKline>> fetchKlines(String symbol, String interval) async {
    final pair = symbol.endsWith('USDT') ? symbol : '${symbol}USDT';
    final uri = Uri.parse(_klinesUrl).replace(
      queryParameters: {'symbol': pair, 'interval': interval, 'limit': '50'},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw BinanceApiException(
        'Failed to fetch klines: ${response.statusCode}',
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final result = <CryptoKline>[];
    for (final item in list) {
      if (item is List) {
        try {
          result.add(CryptoKline.fromBinanceArray(item));
        } catch (_) {
          // Skip malformed kline entries
        }
      }
    }
    return result;
  }
}

class BinanceApiException implements Exception {
  final String message;
  BinanceApiException(this.message);

  @override
  String toString() => 'BinanceApiException: $message';
}
