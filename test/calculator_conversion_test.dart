import 'package:flutter_test/flutter_test.dart';
import 'package:fluxly/data/models/exchange_response.dart';
import 'package:fluxly/providers/calculator_provider.dart';

void main() {
  group('convertCryptoAmount', () {
    test('1 BTC to ETH uses USDT price ratio (not inverted)', () {
      final prices = <String, double>{
        'BTC': 50000,
        'ETH': 2500,
      };
      expect(convertCryptoAmount(1, 'BTC', 'ETH', prices), closeTo(20, 1e-9));
    });

    test('same symbol returns amount', () {
      final prices = <String, double>{'BTC': 50000};
      expect(convertCryptoAmount(3, 'BTC', 'BTC', prices), 3);
    });
  });

  group('convertAmount fiat', () {
    test('USD base: USD to EUR', () {
      final r = ExchangeResponse(
        result: 'success',
        baseCode: 'USD',
        conversionRates: {'USD': 1, 'EUR': 0.92},
      );
      expect(convertAmount(100, 'USD', 'EUR', r), closeTo(92, 1e-9));
    });
  });
}
