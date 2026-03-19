import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/exchange_response.dart';
import 'converter_mode_provider.dart';
import 'crypto_provider.dart';
import 'exchange_rate_provider.dart';
import 'settings_provider.dart';

class CalculatorState {
  final String inputString;
  final double amount;

  const CalculatorState({this.inputString = '0', this.amount = 0});

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
    if (state.inputString == '0' && digit != '.') {
      state = state.copyWith(inputString: digit, amount: _parseAmount(digit));
      return;
    }
    final newInput = state.inputString + digit;
    state = state.copyWith(
      inputString: newInput,
      amount: _parseAmount(newInput),
    );
  }

  void backspace() {
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

  void setFromVoice(double value) {
    final inputString = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
    state = state.copyWith(inputString: inputString, amount: value);
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

double? convertCryptoAmount(
  double amount,
  String fromSymbol,
  String toSymbol,
  Map<String, double> pricesUsdt,
) {
  if (fromSymbol == toSymbol) return amount;
  final fromPrice = pricesUsdt[fromSymbol];
  final toPrice = pricesUsdt[toSymbol];
  if (fromPrice == null || toPrice == null || fromPrice == 0) return null;
  return amount * (toPrice / fromPrice);
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
    final prices = switch (pricesAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (prices != null) {
      final rows = <String>[
        if (settings.isRow2Visible) settings.row2Crypto,
        if (settings.isRow3Visible) settings.row3Crypto,
      ];
      for (final symbol in rows) {
        if (symbol != baseCrypto) {
          final converted = convertCryptoAmount(
            amount,
            baseCrypto,
            symbol,
            prices,
          );
          if (converted != null) result[symbol] = converted;
        }
      }
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
