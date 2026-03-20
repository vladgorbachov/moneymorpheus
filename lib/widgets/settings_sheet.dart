import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxly/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../core/metadata/language_metadata.dart';
import '../providers/settings_provider.dart';
import 'asset_picker.dart';
import 'selector_row.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({
    super.key,
    this.anchoredFromTop = false,
    this.scrollController,
  });

  /// When true, sheet fills [SizedBox] height from [SettingsSheet.show] anchor dialog.
  final bool anchoredFromTop;

  /// When provided (e.g. from [DraggableScrollableSheet]), enables smooth drag-dismiss.
  final ScrollController? scrollController;

  /// Opens settings aligned under the main currency card: top edge [currencyPanelTop] − 2 px.
  /// Falls back to bottom sheet when [currencyPanelTop] is null.
  static Future<void> show(
    BuildContext context, {
    double? currencyPanelTop,
  }) {
    if (currencyPanelTop != null) {
      final panelY = currencyPanelTop;
      return showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withValues(alpha: 0.32),
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          final h = MediaQuery.sizeOf(dialogContext).height;
          final top = (panelY - 2).clamp(0.0, h - 120);
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: top,
                left: 20,
                right: 20,
                bottom: 0,
                child: DraggableScrollableSheet(
                  initialChildSize: 1,
                  minChildSize: 0.35,
                  maxChildSize: 1,
                  builder: (ctx, scrollController) => SettingsSheet(
                    anchoredFromTop: true,
                    scrollController: scrollController,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SettingsSheet(
          anchoredFromTop: false,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => _buildContent(context, ref, settings),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = settings.isDarkMode;
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.98)
        : const Color(0xFF0D0D0D);
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.62)
        : const Color(0xFF0D0D0D).withValues(alpha: 0.55);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFF0D0D0D).withValues(alpha: 0.08);

    final maxH = anchoredFromTop
        ? double.infinity
        : MediaQuery.sizeOf(context).height * 0.95;

    final scrollable = scrollController != null
        ? ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            physics: const ClampingScrollPhysics(),
            children: _settingsChildren(
              context,
              ref,
              settings,
              l10n,
              textColor,
              hintColor,
              dividerColor,
              isDark,
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _settingsChildren(
                context,
                ref,
                settings,
                l10n,
                textColor,
                hintColor,
                dividerColor,
                isDark,
              ),
            ),
          );

    final shell = Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.20),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? accentColor : lightAccentColor)
                .withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: scrollable,
        ),
      ),
    );

    if (anchoredFromTop) {
      return Material(
        color: Colors.transparent,
        child: SizedBox.expand(child: shell),
      );
    }
    return shell;
  }

  List<Widget> _settingsChildren(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    AppLocalizations l10n,
    Color textColor,
    Color hintColor,
    Color dividerColor,
    bool isDark,
  ) {
    return [
      Center(
        child: Container(
          width: 56,
          height: 4,
          decoration: BoxDecoration(
            color: hintColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Center(
        child: Text(
          l10n.settings,
          style: TextStyle(
            fontFamily: kLarazFontFamily,
            fontSize: 35,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
      const SizedBox(height: 18),
      _buildSwitch(
        l10n.darkMode,
        settings.isDarkMode,
        (v) => ref.read(settingsProvider.notifier).setIsDarkMode(v),
        hintColor,
        isDark,
      ),
      Divider(height: 1, color: dividerColor),
      _buildSelectorRow(
        context,
        ref,
        l10n.language,
        LanguageMetadata.displayLabelForCode(settings.locale),
        isDark,
        onTap: () => AssetPicker.showLanguage(
          context,
          currentId: settings.locale.length >= 2
              ? settings.locale.substring(0, 2)
              : settings.locale,
          onSelected: (v) => ref.read(settingsProvider.notifier).setLocale(v),
          isDarkMode: isDark,
          searchHint: l10n.searchLanguage,
        ),
      ),
      Divider(height: 1, color: dividerColor),
      _buildSelectorRow(
        context,
        ref,
        l10n.baseCurrency,
        settings.baseCurrency,
        isDark,
        onTap: () => AssetPicker.showFiat(
          context,
          currentId: settings.baseCurrency,
          onSelected: (v) =>
              ref.read(settingsProvider.notifier).setBaseCurrency(v),
          isDarkMode: isDark,
          searchHint: l10n.searchCurrency,
        ),
      ),
      Divider(height: 1, color: dividerColor),
      _buildSelectorRow(
        context,
        ref,
        l10n.row2Currency,
        settings.row2Currency,
        isDark,
        compactVertical: true,
        onTap: () => AssetPicker.showFiat(
          context,
          currentId: settings.row2Currency,
          onSelected: (v) =>
              ref.read(settingsProvider.notifier).setRow2Currency(v),
          isDarkMode: isDark,
          searchHint: l10n.searchCurrency,
        ),
      ),
      Divider(height: 1, color: dividerColor),
      _buildSwitch(
        l10n.thirdCurrencyRow,
        settings.isRow3Visible,
        (v) => ref.read(settingsProvider.notifier).setIsRow3Visible(v),
        hintColor,
        isDark,
      ),
      if (settings.isRow3Visible) ...[
        Divider(height: 1, color: dividerColor),
        _buildSelectorRow(
          context,
          ref,
          l10n.row3Currency,
          settings.row3Currency,
          isDark,
          compactVertical: true,
          onTap: () => AssetPicker.showFiat(
            context,
            currentId: settings.row3Currency,
            onSelected: (v) =>
                ref.read(settingsProvider.notifier).setRow3Currency(v),
            isDarkMode: isDark,
            searchHint: l10n.searchCurrency,
          ),
        ),
      ],
      const SizedBox(height: 26),
      SizedBox(
        height: 62,
        child: DecoratedBox(
          decoration: glassButtonDecoration(
            isDarkMode: isDark,
            borderRadius: BorderRadius.circular(20),
            highlight: true,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Text(
                  l10n.done,
                  style: TextStyle(
                    fontFamily: kLarazFontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildSelectorRow(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    bool isDark, {
    required VoidCallback onTap,
    bool compactVertical = false,
  }) {
    return SelectorRow(
      label: label,
      value: value,
      onTap: onTap,
      isDarkMode: isDark,
      compactVertical: compactVertical,
    );
  }

  Widget _buildSwitch(
    String label,
    bool value,
    void Function(bool) onChanged,
    Color hintColor,
    bool isDark,
  ) {
    final accent = isDark ? accentColor : lightAccentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: kLarazFontFamily,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: hintColor,
                ),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: accent.withValues(alpha: 0.5),
            activeThumbColor: accent,
          ),
        ],
      ),
    );
  }
}
