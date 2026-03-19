import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../core/metadata/language_metadata.dart';
import '../providers/settings_provider.dart';
import 'asset_picker.dart';
import 'selector_row.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsSheet(),
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
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF0D0D0D).withValues(alpha: 0.55);
    final sheetColor = isDark
        ? const Color(0xFF1A1335)
        : const Color(0xFFFAFDFC);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFF0D0D0D).withValues(alpha: 0.08);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: hintColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.settings,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      onSelected: (v) =>
                          ref.read(settingsProvider.notifier).setLocale(v),
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
                      onSelected: (v) => ref
                          .read(settingsProvider.notifier)
                          .setBaseCurrency(v),
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
                    onTap: () => AssetPicker.showFiat(
                      context,
                      currentId: settings.row2Currency,
                      onSelected: (v) => ref
                          .read(settingsProvider.notifier)
                          .setRow2Currency(v),
                      isDarkMode: isDark,
                      searchHint: l10n.searchCurrency,
                    ),
                  ),
                  _buildSwitch(
                    l10n.showRow2,
                    settings.isRow2Visible,
                    (v) =>
                        ref.read(settingsProvider.notifier).setIsRow2Visible(v),
                    hintColor,
                    isDark,
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildSelectorRow(
                    context,
                    ref,
                    l10n.row3Currency,
                    settings.row3Currency,
                    isDark,
                    onTap: () => AssetPicker.showFiat(
                      context,
                      currentId: settings.row3Currency,
                      onSelected: (v) => ref
                          .read(settingsProvider.notifier)
                          .setRow3Currency(v),
                      isDarkMode: isDark,
                      searchHint: l10n.searchCurrency,
                    ),
                  ),
                  _buildSwitch(
                    l10n.showRow3,
                    settings.isRow3Visible,
                    (v) =>
                        ref.read(settingsProvider.notifier).setIsRow3Visible(v),
                    hintColor,
                    isDark,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? accentColor.withValues(alpha: 0.3)
                            : lightAccentColor.withValues(alpha: 0.2),
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.done),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorRow(
    BuildContext context,
    WidgetRef ref, // ignore: avoid_unused_parameters
    String label,
    String value,
    bool isDark, {
    required VoidCallback onTap,
  }) {
    return SelectorRow(
      label: label,
      value: value,
      onTap: onTap,
      isDarkMode: isDark,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: hintColor)),
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
