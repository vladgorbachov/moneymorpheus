import 'package:flutter/material.dart';

import '../selector_item.dart';

/// Base class for selectable assets (fiat, crypto, language).
/// Enables unified picker and extensibility for new asset types.
abstract class AssetMetadata {
  const AssetMetadata();

  /// Unique id used for selection (e.g. "USD", "BTC", "en").
  String get id;

  /// Primary display label (e.g. "USD", "Bitcoin", "En").
  String get displayLabel;

  /// Optional subtitle (e.g. "US Dollar", "BTCUSDT").
  String? get displaySubtitle;

  /// Optional leading widget (flag emoji, logo, icon).
  Widget? get leadingWidget;

  /// Text used for search. Default: id + displayLabel + subtitle.
  String get searchableText =>
      '$id $displayLabel ${displaySubtitle ?? ''}'.toLowerCase();

  /// Converts to SelectorItem for the unified picker.
  SelectorItem toSelectorItem() => SelectorItem(
        id: id,
        label: displayLabel,
        subtitle: displaySubtitle,
        leading: leadingWidget,
      );
}
