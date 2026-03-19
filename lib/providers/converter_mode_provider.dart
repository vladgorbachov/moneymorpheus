import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

enum ConverterMode { fiat, crypto }

const _keyConverterMode = 'converter_mode';

class ConverterModeNotifier extends AsyncNotifier<ConverterMode> {
  @override
  Future<ConverterMode> build() async {
    final prefs = ref.read(sharedPreferencesAsyncProvider);
    final stored = await prefs.getString(_keyConverterMode);
    return stored == 'crypto' ? ConverterMode.crypto : ConverterMode.fiat;
  }

  Future<void> toggle() async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => ConverterMode.fiat,
    };
    final next = current == ConverterMode.fiat
        ? ConverterMode.crypto
        : ConverterMode.fiat;
    final prefs = ref.read(sharedPreferencesAsyncProvider);
    await prefs.setString(_keyConverterMode, next.name);
    state = AsyncData(next);
  }
}

final converterModeProvider =
    AsyncNotifierProvider<ConverterModeNotifier, ConverterMode>(
      ConverterModeNotifier.new,
    );
