import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../core/metadata/fiat_currency_metadata.dart';
import '../data/models/voice_conversion_intent.dart';
import '../data/services/openai_voice_intent_service.dart';
import '../data/settings_repository.dart';
import '../providers/calculator_provider.dart';
import '../providers/converter_mode_provider.dart';
import '../providers/crypto_provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../providers/settings_provider.dart';

const List<String> _speechLocales = [
  'en_US',
  'fr_FR',
  'es_ES',
  'ru_RU',
  'ar_SA',
  'zh_CN',
  'uk_UA',
  'pl_PL',
  'ro_RO',
];

final _numberRegex = RegExp(r'-?\d+([.,]\d+)?');

double? _extractNumber(String text) {
  final normalized = text.replaceAll(',', '.');
  final match = _numberRegex.firstMatch(normalized);
  if (match == null) return null;
  final group = match.group(0);
  if (group == null) return null;
  return double.tryParse(group.replaceAll(',', '.'));
}

bool _isSupportedFiat(String code) {
  return FiatCurrencyMetadata.supported.any((e) => e.id == code);
}

/// Maps app [locale] (e.g. en, ru, uk) to speech_to_text locale id.
String _speechLocaleIdForApp(String locale) {
  final primary = locale.split(RegExp('[-_]')).first.toLowerCase();
  const map = <String, String>{
    'en': 'en_US',
    'fr': 'fr_FR',
    'es': 'es_ES',
    'ru': 'ru_RU',
    'ar': 'ar_SA',
    'zh': 'zh_CN',
    'uk': 'uk_UA',
    'pl': 'pl_PL',
    'ro': 'ro_RO',
  };
  return map[primary] ?? 'en_US';
}

class MicrophoneButton extends ConsumerStatefulWidget {
  const MicrophoneButton({super.key, this.foregroundColor});

  final Color? foregroundColor;

  @override
  ConsumerState<MicrophoneButton> createState() => _MicrophoneButtonState();
}

class _MicrophoneButtonState extends ConsumerState<MicrophoneButton>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  late AnimationController _pulseController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1);
    _tts.setPitch(1);
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _speakIfEnabled(
    SettingsState settings,
    VoiceConversionIntent intent,
  ) async {
    if (!settings.speechOutputEnabled) return;
    final lang = _ttsLanguageForApp(settings.locale);
    await _tts.setLanguage(lang);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final text = await _buildSpokenSummary(intent);
    if (text.isEmpty || !mounted) return;
    await _tts.speak(text);
  }

  String _ttsLanguageForApp(String locale) {
    final primary = locale.split(RegExp('[-_]')).first.toLowerCase();
    const map = {
      'en': 'en-US',
      'fr': 'fr-FR',
      'es': 'es-ES',
      'ru': 'ru-RU',
      'ar': 'ar-SA',
      'zh': 'zh-CN',
      'uk': 'uk-UA',
      'pl': 'pl-PL',
      'ro': 'ro-RO',
    };
    return map[primary] ?? 'en-US';
  }

  Future<String> _buildSpokenSummary(VoiceConversionIntent intent) async {
    try {
      if (intent.isCrypto) {
        final prices = await ref.read(cryptoPricesUsdtProvider.future);
        final v = convertCryptoAmount(
          intent.amount,
          intent.fromCode,
          intent.toCode,
          prices,
        );
        if (v == null) {
          return '${intent.amount} ${intent.fromCode} to ${intent.toCode}';
        }
        return '${intent.amount} ${intent.fromCode} is about ${v.toStringAsFixed(6)} ${intent.toCode}';
      }
      final rates = await ref.read(exchangeRatesProvider.future);
      final v = convertAmount(
        intent.amount,
        intent.fromCode,
        intent.toCode,
        rates,
      );
      if (v == null) {
        return '${intent.amount} ${intent.fromCode} to ${intent.toCode}';
      }
      return '${intent.amount} ${intent.fromCode} is about ${v.toStringAsFixed(2)} ${intent.toCode}';
    } catch (_) {
      return '${intent.amount} ${intent.fromCode} to ${intent.toCode}';
    }
  }

  Future<void> _applyIntent(VoiceConversionIntent intent) async {
    final settings = ref.read(settingsProvider).value;
    if (settings == null) return;

    if (intent.fromCode == intent.toCode) {
      ref.read(calculatorProvider.notifier).setFromVoice(intent.amount);
      await _speakIfEnabled(settings, intent);
      return;
    }

    if (intent.isCrypto) {
      try {
        final prices = await ref.read(cryptoPricesUsdtProvider.future);
        if (!prices.containsKey(intent.fromCode) ||
            !prices.containsKey(intent.toCode)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unknown crypto pair for current market data'),
              ),
            );
          }
          return;
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not load crypto prices')),
          );
        }
        return;
      }
      await ref.read(converterModeProvider.notifier).setMode(ConverterMode.crypto);
      await ref.read(settingsProvider.notifier).setBaseCrypto(intent.fromCode);
      await ref.read(settingsProvider.notifier).setRow2Crypto(intent.toCode);
      if (!settings.isRow2Visible) {
        await ref.read(settingsProvider.notifier).setIsRow2Visible(true);
      }
    } else {
      if (!_isSupportedFiat(intent.fromCode) || !_isSupportedFiat(intent.toCode)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown fiat code in voice result')),
          );
        }
        return;
      }
      await ref.read(converterModeProvider.notifier).setMode(ConverterMode.fiat);
      await ref.read(settingsProvider.notifier).setBaseCurrency(intent.fromCode);
      await ref.read(settingsProvider.notifier).setRow2Currency(intent.toCode);
      if (!settings.isRow2Visible) {
        await ref.read(settingsProvider.notifier).setIsRow2Visible(true);
      }
    }

    ref.read(calculatorProvider.notifier).setFromVoice(intent.amount);

    final updated = ref.read(settingsProvider).value ?? settings;
    await _speakIfEnabled(updated, intent);
  }

  Future<void> _handleFinalSpeech(String words) async {
    if (!mounted) return;
    final settings = ref.read(settingsProvider).value;
    if (settings == null) return;

    final l10n = AppLocalizations.of(context);
    final key = dotenv.env['OPENAI_API_KEY']?.trim() ?? '';
    final useOpenAi = settings.voiceInterpretation == VoiceInterpretationMode.openAi &&
        key.isNotEmpty;

    if (useOpenAi) {
      try {
        final service = OpenAiVoiceIntentService(apiKey: key);
        final hint = settings.locale.split(RegExp('[-_]')).first;
        final intent = await service.parseUtterance(words, hint);
        if (!mounted) return;
        if (intent == null) {
          final fallback = _extractNumber(words);
          if (fallback != null && fallback >= 0) {
            ref.read(calculatorProvider.notifier).setFromVoice(fallback);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.voiceCouldNotParse ?? 'Could not parse; entered number only',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.voiceCouldNotParse ?? 'Could not understand',
                ),
              ),
            );
          }
          return;
        }
        await _applyIntent(intent);
      } on OpenAiVoiceIntentException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      }
      return;
    }

    // Device recognizer: amount only (Android still uses Google on-device STT).
    final value = _extractNumber(words);
    if (value != null && value >= 0) {
      ref.read(calculatorProvider.notifier).setFromVoice(value);
      if (mounted &&
          settings.voiceInterpretation == VoiceInterpretationMode.openAi &&
          key.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.voiceAddOpenAiKeyHint ??
                  'Add OPENAI_API_KEY to .env for full voice conversion',
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      _pulseController.stop();
      _pulseController.reset();
      return;
    }

    final available = await _speech.initialize(
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
          _pulseController.stop();
          _pulseController.reset();
        }
      },
      onStatus: (status) {
        if (status == stt.SpeechToText.doneStatus && mounted) {
          setState(() => _isListening = false);
          _pulseController.stop();
          _pulseController.reset();
        }
      },
    );
    if (!available || !_speech.isAvailable) return;

    final settings = ref.read(settingsProvider).value;
    final preferred = settings != null
        ? _speechLocaleIdForApp(settings.locale)
        : 'en_US';

    final locales = await _speech.locales();
    final localeIds = locales.map((l) => l.localeId).toSet();
    String? localeId;
    if (localeIds.contains(preferred)) {
      localeId = preferred;
    } else {
      for (final id in _speechLocales) {
        if (localeIds.contains(id)) {
          localeId = id;
          break;
        }
      }
    }

    if (mounted) {
      setState(() => _isListening = true);
    }
    _pulseController.repeat(reverse: true);

    _speech.listen(
      onResult: (result) async {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          await _handleFinalSpeech(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      listenOptions: stt.SpeechListenOptions(partialResults: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor =
        widget.foregroundColor ?? (isDark ? Colors.white : Colors.black);

    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final glowRadius = _isListening
              ? 12.0 + (_pulseController.value * 8)
              : 0.0;
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fgColor.withValues(alpha: 0.1),
              border: Border.all(
                color: fgColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.5),
                        blurRadius: glowRadius,
                        spreadRadius: glowRadius / 4,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening
                  ? Colors.blue.shade200
                  : fgColor.withValues(alpha: 0.8),
              size: 29,
            ),
          );
        },
      ),
    );
  }
}
