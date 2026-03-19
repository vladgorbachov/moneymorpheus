import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/metadata/asset_registry.dart';
import '../core/metadata/crypto_asset_metadata.dart';
import '../providers/crypto_provider.dart';
import 'selector_sheet.dart';

/// Unified asset picker API. Use for fiat, crypto, and language selection.
class AssetPicker {
  AssetPicker._();

  /// Shows fiat currency picker.
  static Future<void> showFiat(
    BuildContext context, {
    required String currentId,
    required void Function(String) onSelected,
    required bool isDarkMode,
    required String searchHint,
  }) {
    return SelectorSheet.show(
      context,
      items: AssetRegistry.fiatCurrenciesToSelectorItems(),
      currentId: currentId,
      onSelected: onSelected,
      isDarkMode: isDarkMode,
      searchHint: searchHint,
    );
  }

  /// Shows crypto asset picker. Requires WidgetRef for async ticker data.
  static Future<void> showCrypto(
    BuildContext context,
    WidgetRef ref, {
    required String currentId,
    required void Function(String) onSelected,
    required bool isDarkMode,
    required String searchHint,
  }) async {
    final tickers = await ref.read(cryptoTickersProvider.future);
    if (!context.mounted) return;
    final assets = tickers.map((t) => CryptoAssetMetadata.fromSymbol(t.baseSymbol)).toList();
    final items = AssetRegistry.cryptoAssetsToSelectorItems(assets);
    return SelectorSheet.show(
      context,
      items: items,
      currentId: currentId,
      onSelected: onSelected,
      isDarkMode: isDarkMode,
      searchHint: searchHint,
    );
  }

  /// Shows language picker.
  static Future<void> showLanguage(
    BuildContext context, {
    required String currentId,
    required void Function(String) onSelected,
    required bool isDarkMode,
    required String searchHint,
  }) {
    return SelectorSheet.show(
      context,
      items: AssetRegistry.languagesToSelectorItems(),
      currentId: currentId,
      onSelected: onSelected,
      isDarkMode: isDarkMode,
      searchHint: searchHint,
    );
  }
}
