import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';

class SettingsState {
  final String baseCurrency;
  final String row2Currency;
  final String row3Currency;
  final String baseCrypto;
  final String row2Crypto;
  final String row3Crypto;
  final bool isRow2Visible;
  final bool isRow3Visible;
  final bool isDarkMode;
  final String locale;

  const SettingsState({
    this.baseCurrency = 'USD',
    this.row2Currency = 'EUR',
    this.row3Currency = 'UAH',
    this.baseCrypto = 'BTC',
    this.row2Crypto = 'ETH',
    this.row3Crypto = 'USDT',
    this.isRow2Visible = true,
    this.isRow3Visible = false,
    this.isDarkMode = true,
    this.locale = 'en',
  });

  SettingsState copyWith({
    String? baseCurrency,
    String? row2Currency,
    String? row3Currency,
    String? baseCrypto,
    String? row2Crypto,
    String? row3Crypto,
    bool? isRow2Visible,
    bool? isRow3Visible,
    bool? isDarkMode,
    String? locale,
  }) {
    return SettingsState(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      row2Currency: row2Currency ?? this.row2Currency,
      row3Currency: row3Currency ?? this.row3Currency,
      baseCrypto: baseCrypto ?? this.baseCrypto,
      row2Crypto: row2Crypto ?? this.row2Crypto,
      row3Crypto: row3Crypto ?? this.row3Crypto,
      isRow2Visible: isRow2Visible ?? this.isRow2Visible,
      isRow3Visible: isRow3Visible ?? this.isRow3Visible,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
    );
  }

  Locale get localeValue {
    final parts = locale.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(locale);
  }
}

final sharedPreferencesAsyncProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(sharedPreferencesAsyncProvider));
});

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  Future<SettingsState> build() async {
    final baseCurrency = await _repository.getBaseCurrency();
    final row2Currency = await _repository.getRow2Currency();
    final row3Currency = await _repository.getRow3Currency();
    final baseCrypto = await _repository.getBaseCrypto();
    final row2Crypto = await _repository.getRow2Crypto();
    final row3Crypto = await _repository.getRow3Crypto();
    final isRow2Visible = await _repository.getIsRow2Visible();
    final isRow3Visible = await _repository.getIsRow3Visible();
    final isDarkMode = await _repository.getIsDarkMode();
    final locale = await _repository.getLocale();
    return SettingsState(
      baseCurrency: baseCurrency,
      row2Currency: row2Currency,
      row3Currency: row3Currency,
      baseCrypto: baseCrypto,
      row2Crypto: row2Crypto,
      row3Crypto: row3Crypto,
      isRow2Visible: isRow2Visible,
      isRow3Visible: isRow3Visible,
      isDarkMode: isDarkMode,
      locale: locale,
    );
  }

  Future<void> _update(
    Future<void> Function() fn,
    SettingsState Function(SettingsState) update,
  ) async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current == null) return;
    await fn();
    state = AsyncValue.data(update(current));
  }

  Future<void> setBaseCurrency(String value) async {
    await _update(
      () => _repository.setBaseCurrency(value),
      (s) => s.copyWith(baseCurrency: value),
    );
  }

  Future<void> setRow2Currency(String value) async {
    await _update(
      () => _repository.setRow2Currency(value),
      (s) => s.copyWith(row2Currency: value),
    );
  }

  Future<void> setRow3Currency(String value) async {
    await _update(
      () => _repository.setRow3Currency(value),
      (s) => s.copyWith(row3Currency: value),
    );
  }

  Future<void> setBaseCrypto(String value) async {
    await _update(
      () => _repository.setBaseCrypto(value),
      (s) => s.copyWith(baseCrypto: value),
    );
  }

  Future<void> setRow2Crypto(String value) async {
    await _update(
      () => _repository.setRow2Crypto(value),
      (s) => s.copyWith(row2Crypto: value),
    );
  }

  Future<void> setRow3Crypto(String value) async {
    await _update(
      () => _repository.setRow3Crypto(value),
      (s) => s.copyWith(row3Crypto: value),
    );
  }

  Future<void> setIsRow2Visible(bool value) async {
    await _update(
      () => _repository.setIsRow2Visible(value),
      (s) => s.copyWith(isRow2Visible: value),
    );
  }

  Future<void> setIsRow3Visible(bool value) async {
    await _update(
      () => _repository.setIsRow3Visible(value),
      (s) => s.copyWith(isRow3Visible: value),
    );
  }

  Future<void> setIsDarkMode(bool value) async {
    await _update(
      () => _repository.setIsDarkMode(value),
      (s) => s.copyWith(isDarkMode: value),
    );
  }

  Future<void> setLocale(String value) async {
    await _update(
      () => _repository.setLocale(value),
      (s) => s.copyWith(locale: value),
    );
  }

  Future<void> swapBaseWithRow2() async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current == null) return;
    await _repository.setBaseCurrency(current.row2Currency);
    await _repository.setRow2Currency(current.baseCurrency);
    state = AsyncValue.data(
      SettingsState(
        baseCurrency: current.row2Currency,
        row2Currency: current.baseCurrency,
        row3Currency: current.row3Currency,
        baseCrypto: current.baseCrypto,
        row2Crypto: current.row2Crypto,
        row3Crypto: current.row3Crypto,
        isRow2Visible: current.isRow2Visible,
        isRow3Visible: current.isRow3Visible,
        isDarkMode: current.isDarkMode,
        locale: current.locale,
      ),
    );
  }

  Future<void> swapBaseCryptoWithRow2Crypto() async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current == null) return;
    await _repository.setBaseCrypto(current.row2Crypto);
    await _repository.setRow2Crypto(current.baseCrypto);
    state = AsyncValue.data(
      SettingsState(
        baseCurrency: current.baseCurrency,
        row2Currency: current.row2Currency,
        row3Currency: current.row3Currency,
        baseCrypto: current.row2Crypto,
        row2Crypto: current.baseCrypto,
        row3Crypto: current.row3Crypto,
        isRow2Visible: current.isRow2Visible,
        isRow3Visible: current.isRow3Visible,
        isDarkMode: current.isDarkMode,
        locale: current.locale,
      ),
    );
  }
}
