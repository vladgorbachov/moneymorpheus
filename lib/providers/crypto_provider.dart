import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/crypto_logos.dart';
import '../data/models/crypto_kline.dart';
import '../data/models/crypto_ticker.dart';
import '../data/services/binance_api_service.dart';
import 'crypto_list_sort_provider.dart';
import 'favourites_provider.dart';
import 'settings_provider.dart';

final binanceApiServiceProvider = Provider<BinanceApiService>((ref) {
  final prefs = ref.read(sharedPreferencesAsyncProvider);
  return BinanceApiService(prefs);
});

class CryptoSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) => state = newQuery;
}

final cryptoSearchQueryProvider =
    NotifierProvider<CryptoSearchQueryNotifier, String>(
      CryptoSearchQueryNotifier.new,
    );

final cryptoTickersProvider = FutureProvider<List<CryptoTicker>>((ref) async {
  final service = ref.watch(binanceApiServiceProvider);
  return service.fetchTickers();
});

final cryptoFilteredTickersProvider = FutureProvider<List<CryptoTicker>>((
  ref,
) async {
  final tickers = await ref.watch(cryptoTickersProvider.future);
  final query = ref.watch(cryptoSearchQueryProvider).trim().toUpperCase();
  final favouritesAsync = ref.watch(favouritesProvider);
  final sortAsync = ref.watch(cryptoListSortProvider);
  final sort = switch (sortAsync) {
    AsyncData(:final value) => value,
    _ => CryptoListSort.quoteVolumeDesc,
  };

  final favourites = switch (favouritesAsync) {
    AsyncData(:final value) => value,
    _ => <String>{},
  };

  var filtered = tickers;
  if (query.isNotEmpty) {
    filtered = tickers.where((t) {
      final base = t.baseSymbol.toUpperCase();
      final full = t.symbol.toUpperCase();
      final name = (cryptoNames[t.baseSymbol] ?? '').toUpperCase();
      return base.contains(query) ||
          full.contains(query) ||
          name.contains(query);
    }).toList();
  }

  int compareBySort(CryptoTicker a, CryptoTicker b) {
    switch (sort) {
      case CryptoListSort.quoteVolumeDesc:
        return b.quoteVolume24h.compareTo(a.quoteVolume24h);
      case CryptoListSort.quoteVolumeAsc:
        return a.quoteVolume24h.compareTo(b.quoteVolume24h);
      case CryptoListSort.symbolAsc:
        return a.baseSymbol.toUpperCase().compareTo(b.baseSymbol.toUpperCase());
      case CryptoListSort.symbolDesc:
        return b.baseSymbol.toUpperCase().compareTo(a.baseSymbol.toUpperCase());
    }
  }

  filtered.sort((a, b) {
    final aFav = favourites.contains(a.baseSymbol);
    final bFav = favourites.contains(b.baseSymbol);
    if (aFav != bFav) return aFav ? -1 : 1;
    return compareBySort(a, b);
  });

  return filtered;
});

/// Ticker for a single symbol. Reuses cryptoTickersProvider.
final cryptoTickerBySymbolProvider =
    FutureProvider.family<CryptoTicker?, String>((ref, symbol) async {
      final tickers = await ref.watch(cryptoTickersProvider.future);
      final pair = symbol.endsWith('USDT') ? symbol : '${symbol}USDT';
      for (final t in tickers) {
        if (t.symbol == pair) return t;
      }
      return null;
    });

/// Map of base symbol (e.g. BTC, ETH) to price in USDT.
final cryptoPricesUsdtProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  final tickers = await ref.watch(cryptoTickersProvider.future);
  final map = <String, double>{'USDT': 1.0};
  for (final t in tickers) {
    map[t.baseSymbol] = t.price;
  }
  return map;
});

final cryptoKlinesProvider =
    FutureProvider.family<
      List<CryptoKline>,
      ({String symbol, String interval})
    >((ref, params) async {
      final service = ref.watch(binanceApiServiceProvider);
      return service.fetchKlines(params.symbol, params.interval);
    });
