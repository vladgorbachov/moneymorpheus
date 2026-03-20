import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

/// Binance 24h ticker has no market cap; [quoteVolume24h] (USDT) is used as the sort proxy.
enum CryptoListSort {
  /// Default: largest USDT quote volume first (common cap/volume proxy).
  quoteVolumeDesc,

  quoteVolumeAsc,
  symbolAsc,
  symbolDesc,
}

extension CryptoListSortStorage on CryptoListSort {
  static CryptoListSort fromName(String? name) {
    for (final v in CryptoListSort.values) {
      if (v.name == name) return v;
    }
    return CryptoListSort.quoteVolumeDesc;
  }
}

class CryptoListSortNotifier extends AsyncNotifier<CryptoListSort> {
  static const _key = 'crypto_list_sort_v1';

  @override
  Future<CryptoListSort> build() async {
    final prefs = ref.read(sharedPreferencesAsyncProvider);
    final raw = await prefs.getString(_key);
    return CryptoListSortStorage.fromName(raw);
  }

  Future<void> setSort(CryptoListSort sort) async {
    final prefs = ref.read(sharedPreferencesAsyncProvider);
    await prefs.setString(_key, sort.name);
    state = AsyncData(sort);
  }
}

final cryptoListSortProvider =
    AsyncNotifierProvider<CryptoListSortNotifier, CryptoListSort>(
  CryptoListSortNotifier.new,
);
