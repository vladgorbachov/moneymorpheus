import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';

class SettingsState {
  final String baseCurrency;
  final String row2Currency;
  final String row3Currency;
  final bool isRow2Visible;
  final bool isRow3Visible;

  const SettingsState({
    this.baseCurrency = 'USD',
    this.row2Currency = 'EUR',
    this.row3Currency = 'UAH',
    this.isRow2Visible = true,
    this.isRow3Visible = true,
  });

  SettingsState copyWith({
    String? baseCurrency,
    String? row2Currency,
    String? row3Currency,
    bool? isRow2Visible,
    bool? isRow3Visible,
  }) {
    return SettingsState(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      row2Currency: row2Currency ?? this.row2Currency,
      row3Currency: row3Currency ?? this.row3Currency,
      isRow2Visible: isRow2Visible ?? this.isRow2Visible,
      isRow3Visible: isRow3Visible ?? this.isRow3Visible,
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

class SettingsNotifier extends StateNotifier<AsyncValue<SettingsState>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final baseCurrency = await _repository.getBaseCurrency();
      final row2Currency = await _repository.getRow2Currency();
      final row3Currency = await _repository.getRow3Currency();
      final isRow2Visible = await _repository.getIsRow2Visible();
      final isRow3Visible = await _repository.getIsRow3Visible();
      state = AsyncValue.data(SettingsState(
        baseCurrency: baseCurrency,
        row2Currency: row2Currency,
        row3Currency: row3Currency,
        isRow2Visible: isRow2Visible,
        isRow3Visible: isRow3Visible,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setBaseCurrency(String value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repository.setBaseCurrency(value);
    state = AsyncValue.data(current.copyWith(baseCurrency: value));
  }

  Future<void> setRow2Currency(String value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repository.setRow2Currency(value);
    state = AsyncValue.data(current.copyWith(row2Currency: value));
  }

  Future<void> setRow3Currency(String value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repository.setRow3Currency(value);
    state = AsyncValue.data(current.copyWith(row3Currency: value));
  }

  Future<void> setIsRow2Visible(bool value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repository.setIsRow2Visible(value);
    state = AsyncValue.data(current.copyWith(isRow2Visible: value));
  }

  Future<void> setIsRow3Visible(bool value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repository.setIsRow3Visible(value);
    state = AsyncValue.data(current.copyWith(isRow3Visible: value));
  }

  Future<void> swapBaseWithRow2() async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repository.setBaseCurrency(current.row2Currency);
    await _repository.setRow2Currency(current.baseCurrency);
    state = AsyncValue.data(SettingsState(
      baseCurrency: current.row2Currency,
      row2Currency: current.baseCurrency,
      row3Currency: current.row3Currency,
      isRow2Visible: current.isRow2Visible,
      isRow3Visible: current.isRow3Visible,
    ));
  }
}
