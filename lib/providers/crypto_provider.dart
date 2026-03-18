import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/crypto_kline.dart';
import '../data/models/crypto_ticker.dart';
import '../data/services/binance_api_service.dart';
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

final cryptoFilteredTickersProvider = FutureProvider<List<CryptoTicker>>((
  ref,
) async {
  final service = ref.watch(binanceApiServiceProvider);
  final query = ref.watch(cryptoSearchQueryProvider).trim().toUpperCase();

  final tickers = await service.fetchTickers();

  if (query.isEmpty) return tickers;

  return tickers.where((t) {
    final base = t.baseSymbol.toUpperCase();
    final full = t.symbol.toUpperCase();
    return base.contains(query) || full.contains(query);
  }).toList();
});

final cryptoKlinesProvider =
    FutureProvider.family<
      List<CryptoKline>,
      ({String symbol, String interval})
    >((ref, params) async {
      final service = ref.watch(binanceApiServiceProvider);
      return service.fetchKlines(params.symbol, params.interval);
    });
