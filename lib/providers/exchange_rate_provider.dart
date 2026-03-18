import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exchange_rate_service.dart';
import '../data/models/exchange_response.dart';
import 'settings_provider.dart';

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  final prefs = ref.read(sharedPreferencesAsyncProvider);
  return ExchangeRateService(prefs);
});

final exchangeRatesProvider = FutureProvider<ExchangeResponse>((ref) async {
  final settingsAsync = ref.watch(settingsProvider);
  final settingsState = switch (settingsAsync) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (settingsState == null) {
    throw Exception('Settings not loaded');
  }
  final service = ref.watch(exchangeRateServiceProvider);
  return service.fetchRates(settingsState.baseCurrency);
});
