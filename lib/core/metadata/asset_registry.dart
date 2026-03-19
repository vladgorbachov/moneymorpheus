import '../selector_item.dart';
import 'crypto_asset_metadata.dart';
import 'fiat_currency_metadata.dart';
import 'language_metadata.dart';

/// Registry for asset metadata. Provides unified access and SelectorItem conversion.
/// Extensible: add new asset types by implementing AssetMetadata.
class AssetRegistry {
  AssetRegistry._();

  static List<SelectorItem> fiatCurrenciesToSelectorItems() =>
      FiatCurrencyMetadata.supported.map((e) => e.toSelectorItem()).toList();

  static List<SelectorItem> languagesToSelectorItems() =>
      LanguageMetadata.supported.map((e) => e.toSelectorItem()).toList();

  static List<SelectorItem> cryptoAssetsToSelectorItems(
    List<CryptoAssetMetadata> assets,
  ) =>
      assets.map((e) => e.toSelectorItem()).toList();
}
