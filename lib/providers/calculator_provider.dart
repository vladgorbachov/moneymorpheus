import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data/models/exchange_response.dart';
import 'converter_mode_provider.dart';
import 'crypto_provider.dart';
import 'exchange_rate_provider.dart';
import 'settings_provider.dart';

class CalculatorState {
  final String inputString;
  final double amount;

  const CalculatorState({this.inputString = '0.0', this.amount = 0});

  CalculatorState copyWith({String? inputString, double? amount}) {
    return CalculatorState(
      inputString: inputString ?? this.inputString,
      amount: amount ?? this.amount,
    );
  }
}

final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(
      CalculatorNotifier.new,
    );

class CalculatorNotifier extends Notifier<CalculatorState> {
  @override
  CalculatorState build() => const CalculatorState();

  void appendDigit(String digit) {
    if (digit == '.' && state.inputString.contains('.')) return;
    if (state.inputString == '0' && digit == '.') {
      state = state.copyWith(inputString: '0.', amount: 0);
      return;
    }
    if (digit != '.' &&
        (state.inputString == '0' || state.inputString == '0.0')) {
      final next = _parseAmount(digit);
      if (next > kMaxConverterAmount) return;
      state = state.copyWith(inputString: digit, amount: next);
      return;
    }
    final newInput = state.inputString + digit;
    final nextAmount = _parseAmount(newInput);
    if (nextAmount > kMaxConverterAmount) return;
    state = state.copyWith(
      inputString: newInput,
      amount: nextAmount,
    );
  }

  void backspace() {
    if (state.inputString == '0' || state.inputString == '0.0') {
      state = const CalculatorState();
      return;
    }
    if (state.inputString.length <= 1) {
      state = const CalculatorState();
      return;
    }
    final newInput = state.inputString.substring(
      0,
      state.inputString.length - 1,
    );
    state = state.copyWith(
      inputString: newInput,
      amount: _parseAmount(newInput),
    );
  }

  void clear() {
    state = const CalculatorState();
  }

  double _parseAmount(String input) {
    return double.tryParse(input) ?? 0;
  }
}

double? convertAmount(
  double amount,
  String fromCurrency,
  String toCurrency,
  ExchangeResponse response,
) {
  if (fromCurrency == toCurrency) return amount;
  final fromRate = response.conversionRates[fromCurrency];
  final toRate = response.conversionRates[toCurrency];
  if (fromRate == null || toRate == null) return null;
  return amount * (toRate / fromRate);
}

/// Converts [amount] of [fromSymbol] into units of [toSymbol] using Binance USDT prices.
/// Value in USDT is preserved: amount * fromPrice / toPrice.
double? convertCryptoAmount(
  double amount,
  String fromSymbol,
  String toSymbol,
  Map<String, double> pricesUsdt,
) {
  if (fromSymbol == toSymbol) return amount;
  final fromPrice = pricesUsdt[fromSymbol];
  final toPrice = pricesUsdt[toSymbol];
  if (fromPrice == null || toPrice == null || toPrice == 0) return null;
  return amount * (fromPrice / toPrice);
}

final convertedAmountsProvider = Provider<Map<String, double>>((ref) {
  final calculator = ref.watch(calculatorProvider);
  final settingsAsync = ref.watch(settingsProvider);
  final modeAsync = ref.watch(converterModeProvider);

  final settings = switch (settingsAsync) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (settings == null) return {};

  final amount = calculator.amount;
  final result = <String, double>{};
  final mode = switch (modeAsync) {
    AsyncData(:final value) => value,
    _ => ConverterMode.fiat,
  };

  if (mode == ConverterMode.crypto) {
    final baseCrypto = settings.baseCrypto;
    result[baseCrypto] = amount;
    final pricesAsync = ref.watch(cryptoPricesUsdtProvider);
    final ratesAsync = ref.watch(exchangeRatesProvider);
    final prices = switch (pricesAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final rates = switch (ratesAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (prices == null || rates == null) return result;

    // Binance: base asset price in USDT (~USD). Fiat rows: bridge via USD then exchangerate API.
    final baseUsdPerUnit = prices[baseCrypto];
    if (baseUsdPerUnit == null) return result;
    final valueUsd = amount * baseUsdPerUnit;

    final fiatRows = <String>[
      if (settings.isRow2Visible) settings.row2Currency,
      if (settings.isRow3Visible) settings.row3Currency,
    ];
    for (final fiat in fiatRows) {
      if (fiat == baseCrypto) continue;
      final converted = convertAmount(valueUsd, 'USD', fiat, rates);
      if (converted != null) result[fiat] = converted;
    }
    return result;
  }

  final base = settings.baseCurrency;
  result[base] = amount;

  final ratesAsync = ref.watch(exchangeRatesProvider);
  final rates = switch (ratesAsync) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (rates != null) {
    final rows = [
      if (settings.isRow2Visible) settings.row2Currency,
      if (settings.isRow3Visible) settings.row3Currency,
    ];
    for (final currency in rows) {
      if (currency != base) {
        final converted = convertAmount(amount, base, currency, rates);
        if (converted != null) result[currency] = converted;
      }
    }
  }

  return result;
});
