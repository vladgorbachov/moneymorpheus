import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../providers/calculator_provider.dart';
import '../providers/converter_mode_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/asset_picker.dart';
import '../widgets/currency_row.dart';
import '../widgets/custom_numpad.dart';
import '../widgets/microphone_button.dart';
import '../widgets/settings_sheet.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final amounts = ref.watch(convertedAmountsProvider);

    return settingsAsync.when(
      data: (settings) {
        final modeAsync = ref.watch(converterModeProvider);
        final mode = switch (modeAsync) {
          AsyncData(:final value) => value,
          _ => null,
        };
        final isDark = settings.isDarkMode;
        final iconColor = isDark
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.85);

        return Scaffold(
          body: SafeArea(
            child: Container(
              decoration: buildThemedWallpaper(isDark),
              child: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildAppBar(context, iconColor),
                          const SizedBox(height: 6),
                          Expanded(
                            child: _buildDisplayArea(
                              context,
                              ref,
                              settings,
                              amounts,
                              mode,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 11,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: const CustomNumpad(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: darkBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: Colors.red.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: iconColor, size: 28),
            onPressed: () => SettingsSheet.show(context),
          ),
          const MicrophoneButton(),
        ],
      ),
    );
  }

  Widget _buildDisplayArea(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    Map<String, double> amounts,
    ConverterMode? mode,
  ) {
    final isDark = settings.isDarkMode;
    final isCrypto = mode == ConverterMode.crypto;

    final rows = <Widget>[
      CurrencyRow(
        currencyCode: isCrypto ? settings.baseCrypto : settings.baseCurrency,
        amount: amounts[isCrypto ? settings.baseCrypto : settings.baseCurrency] ?? 0,
        isDarkMode: isDark,
        onTap: () => isCrypto
            ? AssetPicker.showCrypto(
                context,
                ref,
                currentId: settings.baseCrypto,
                onSelected: (v) => ref.read(settingsProvider.notifier).setBaseCrypto(v),
                isDarkMode: isDark,
                searchHint: AppLocalizations.of(context)!.searchCrypto,
              )
            : AssetPicker.showFiat(
                context,
                currentId: settings.baseCurrency,
                onSelected: (v) => ref.read(settingsProvider.notifier).setBaseCurrency(v),
                isDarkMode: isDark,
                searchHint: AppLocalizations.of(context)!.searchCurrency,
              ),
      ),
      if (settings.isRow2Visible)
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: CurrencyRow(
            currencyCode: isCrypto ? settings.row2Crypto : settings.row2Currency,
            amount: amounts[isCrypto ? settings.row2Crypto : settings.row2Currency] ?? 0,
            isDarkMode: isDark,
            onTap: () => isCrypto
                ? AssetPicker.showCrypto(
                    context,
                    ref,
                    currentId: settings.row2Crypto,
                    onSelected: (v) => ref.read(settingsProvider.notifier).setRow2Crypto(v),
                    isDarkMode: isDark,
                    searchHint: AppLocalizations.of(context)!.searchCrypto,
                  )
                : AssetPicker.showFiat(
                    context,
                    currentId: settings.row2Currency,
                    onSelected: (v) => ref.read(settingsProvider.notifier).setRow2Currency(v),
                    isDarkMode: isDark,
                    searchHint: AppLocalizations.of(context)!.searchCurrency,
                  ),
          ),
        ),
      if (settings.isRow3Visible)
        CurrencyRow(
          currencyCode: isCrypto ? settings.row3Crypto : settings.row3Currency,
          amount: amounts[isCrypto ? settings.row3Crypto : settings.row3Currency] ?? 0,
          isDarkMode: isDark,
          showDivider: false,
          onTap: () => isCrypto
              ? AssetPicker.showCrypto(
                  context,
                  ref,
                  currentId: settings.row3Crypto,
                  onSelected: (v) => ref.read(settingsProvider.notifier).setRow3Crypto(v),
                  isDarkMode: isDark,
                  searchHint: AppLocalizations.of(context)!.searchCrypto,
                )
              : AssetPicker.showFiat(
                  context,
                  currentId: settings.row3Currency,
                  onSelected: (v) => ref.read(settingsProvider.notifier).setRow3Currency(v),
                  isDarkMode: isDark,
                  searchHint: AppLocalizations.of(context)!.searchCurrency,
                ),
        ),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.16),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.34),
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
          ),
        ),
        if (settings.isRow2Visible)
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.12),
              child: _SwapButton(
                isDarkMode: isDark,
                onTap: () => isCrypto
                    ? ref.read(settingsProvider.notifier).swapBaseCryptoWithRow2Crypto()
                    : ref.read(settingsProvider.notifier).swapBaseWithRow2(),
              ),
            ),
          ),
      ],
    );
  }
}

class _SwapButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTap;

  const _SwapButton({required this.isDarkMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor = isDarkMode ? Colors.white : Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 70,
          height: 70,
          decoration: glassButtonDecoration(
            isDarkMode: isDarkMode,
            borderRadius: BorderRadius.circular(999),
            highlight: true,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.swap_vert_rounded, size: 30, color: iconColor),
        ),
      ),
    );
  }
}
