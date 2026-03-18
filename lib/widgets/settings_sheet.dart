import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../core/currencies.dart';
import '../providers/settings_provider.dart';
import 'glass_card.dart';

const List<MapEntry<String, String>> _supportedLocales = [
  MapEntry('en', 'English'),
  MapEntry('fr', 'Français'),
  MapEntry('es', 'Español'),
  MapEntry('ru', 'Русский'),
  MapEntry('ar', 'العربية'),
  MapEntry('zh', '中文'),
  MapEntry('uk', 'Українська'),
  MapEntry('pl', 'Polski'),
  MapEntry('ro', 'Română'),
];

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
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.black.withValues(alpha: 0.9);
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.5);
    final sheetColor = (isDark ? Colors.black : Colors.white).withValues(
      alpha: 0.3,
    );
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor, width: 1),
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
                  Text(
                    l10n.settings,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitch(
                    l10n.darkMode,
                    settings.isDarkMode,
                    (v) => ref.read(settingsProvider.notifier).setIsDarkMode(v),
                    textColor,
                    hintColor,
                  ),
                  const SizedBox(height: 16),
                  _buildLocaleSelector(
                    context,
                    ref,
                    settings,
                    l10n,
                    textColor,
                    hintColor,
                    isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildDropdown(
                    l10n.baseCurrency,
                    settings.baseCurrency,
                    (v) =>
                        ref.read(settingsProvider.notifier).setBaseCurrency(v),
                    textColor,
                    hintColor,
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    l10n.row2Currency,
                    settings.row2Currency,
                    (v) =>
                        ref.read(settingsProvider.notifier).setRow2Currency(v),
                    textColor,
                    hintColor,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSwitch(
                    l10n.showRow2,
                    settings.isRow2Visible,
                    (v) =>
                        ref.read(settingsProvider.notifier).setIsRow2Visible(v),
                    textColor,
                    hintColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    l10n.row3Currency,
                    settings.row3Currency,
                    (v) =>
                        ref.read(settingsProvider.notifier).setRow3Currency(v),
                    textColor,
                    hintColor,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSwitch(
                    l10n.showRow3,
                    settings.isRow3Visible,
                    (v) =>
                        ref.read(settingsProvider.notifier).setIsRow3Visible(v),
                    textColor,
                    hintColor,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.2),
                        foregroundColor: textColor,
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

  Widget _buildLocaleSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    AppLocalizations l10n,
    Color textColor,
    Color hintColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.language, style: TextStyle(fontSize: 14, color: hintColor)),
        const SizedBox(height: 8),
        GlassCard(
          isDarkMode: isDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButton<String>(
            value: settings.locale.length >= 2
                ? settings.locale.substring(0, 2)
                : settings.locale,
            isExpanded: true,
            dropdownColor: isDark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF5F5F5),
            style: TextStyle(color: textColor, fontSize: 16),
            underline: const SizedBox(),
            items: _supportedLocales
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) ref.read(settingsProvider.notifier).setLocale(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    void Function(String) onChanged,
    Color textColor,
    Color hintColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: hintColor)),
        const SizedBox(height: 8),
        GlassCard(
          isDarkMode: isDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: isDark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF5F5F5),
            style: TextStyle(color: textColor, fontSize: 16),
            underline: const SizedBox(),
            items: supportedCurrencies
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(
    String label,
    bool value,
    void Function(bool) onChanged,
    Color textColor,
    Color hintColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: hintColor)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: accentColor.withValues(alpha: 0.5),
          activeThumbColor: accentColor,
        ),
      ],
    );
  }
}
