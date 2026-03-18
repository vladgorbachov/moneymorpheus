import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../providers/calculator_provider.dart';

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

class MicrophoneButton extends ConsumerStatefulWidget {
  const MicrophoneButton({super.key});

  @override
  ConsumerState<MicrophoneButton> createState() => _MicrophoneButtonState();
}

class _MicrophoneButtonState extends ConsumerState<MicrophoneButton>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
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

    final locales = await _speech.locales();
    final localeIds = locales.map((l) => l.localeId).toSet();
    String? localeId;
    for (final preferred in _speechLocales) {
      if (localeIds.contains(preferred)) {
        localeId = preferred;
        break;
      }
    }

    setState(() => _isListening = true);
    _pulseController.repeat(reverse: true);

    _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          final value = _extractNumber(result.recognizedWords);
          if (value != null && value >= 0) {
            ref.read(calculatorProvider.notifier).setFromVoice(value);
          }
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
    final fgColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final glowRadius = _isListening ? 12.0 + (_pulseController.value * 8) : 0.0;
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
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
