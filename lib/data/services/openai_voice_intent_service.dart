import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/metadata/fiat_currency_metadata.dart';
import '../models/voice_conversion_intent.dart';

/// Parses multilingual natural language into a structured conversion using OpenAI.
class OpenAiVoiceIntentService {
  OpenAiVoiceIntentService({
    required this.apiKey,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static String _supportedFiatLine() {
    return FiatCurrencyMetadata.supported.map((e) => e.id).join(', ');
  }

  static String _cryptoLine() {
    return const [
      'BTC',
      'ETH',
      'USDT',
      'BNB',
      'SOL',
      'XRP',
      'USDC',
      'DOGE',
      'ADA',
      'AVAX',
      'TRX',
      'LINK',
      'DOT',
      'MATIC',
      'LTC',
      'UNI',
    ].join(', ');
  }

  /// [userLanguageHint] is BCP 47 (e.g. en, ru, uk) for context only.
  Future<VoiceConversionIntent?> parseUtterance(
    String utterance,
    String userLanguageHint,
  ) async {
    final trimmed = utterance.trim();
    if (trimmed.isEmpty) return null;
    if (apiKey.isEmpty) return null;

    final system = StringBuffer()
      ..writeln(
        'You help a currency converter Android app. Users speak any language. '
        'Extract ONE conversion: amount, source asset, target asset.',
      )
      ..writeln(
        'Return ONLY valid JSON with keys: '
        '"amount" (number), "from" (string), "to" (string), "kind" ("fiat" or "crypto").',
      )
      ..writeln(
        'Both assets must be the same kind: either both fiat ISO 4217 codes (3 letters) '
        'or both crypto tickers (e.g. BTC, ETH). No fiat-to-crypto mixes.',
      )
      ..writeln(
        'If the user mixes fiat and crypto or you are unsure, return {"error":"..."} with a short reason.',
      )
      ..writeln('Examples:')
      ..writeln(
        '"Convert 100 US dollars to Romanian lei" -> '
        '{"amount":100,"from":"USD","to":"RON","kind":"fiat"}',
      )
      ..writeln(
        '"Сколько украинских гривен в ста евро" -> '
        '{"amount":100,"from":"EUR","to":"UAH","kind":"fiat"}',
      )
      ..writeln('Supported fiat codes include: ${_supportedFiatLine()}')
      ..writeln('Common crypto symbols: ${_cryptoLine()} (and other standard tickers).')
      ..writeln('User UI language hint: $userLanguageHint');

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': system.toString()},
        {'role': 'user', 'content': trimmed},
      ],
      'temperature': 0.2,
    });

    final response = await _http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw OpenAiVoiceIntentException(
        'OpenAI HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;
    final first = choices.first as Map<String, dynamic>;
    final message = first['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.isEmpty) return null;

    final json = jsonDecode(content) as Map<String, dynamic>;
    if (json.containsKey('error')) return null;

    final amount = (json['amount'] as num?)?.toDouble();
    final from = (json['from'] as String?)?.toUpperCase().trim();
    final to = (json['to'] as String?)?.toUpperCase().trim();
    final kind = (json['kind'] as String?)?.toLowerCase().trim();

    if (amount == null || amount < 0 || from == null || to == null || kind == null) {
      return null;
    }
    if (from.isEmpty || to.isEmpty) return null;

    final isCrypto = kind == 'crypto';
    if (!isCrypto && kind != 'fiat') return null;

    return VoiceConversionIntent(
      amount: amount,
      fromCode: from,
      toCode: to,
      isCrypto: isCrypto,
    );
  }
}

class OpenAiVoiceIntentException implements Exception {
  OpenAiVoiceIntentException(this.message);
  final String message;

  @override
  String toString() => message;
}
