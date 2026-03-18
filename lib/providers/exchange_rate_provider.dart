import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exchange_rate_service.dart';
import '../data/models/exchange_response.dart';
import 'settings_provider.dart';

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService();
});

final exchangeRatesProvider = FutureProvider<ExchangeResponse>((ref) async {
  final settings = ref.watch(settingsProvider);
  final settingsState = settings.valueOrNull;
  if (settingsState == null) {
    throw Exception('Settings not loaded');
  }
  final service = ref.watch(exchangeRateServiceProvider);
  return service.fetchRates(settingsState.baseCurrency);
});
