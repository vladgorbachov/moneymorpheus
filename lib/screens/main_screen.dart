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
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [darkGradientStart, darkGradientEnd]
                            : [lightGradientStart, lightGradientEnd],
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildAppBar(context, iconColor),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                _buildDisplayArea(
                                  context,
                                  ref,
                                  settings,
                                  amounts,
                                  mode,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: isDark ? darkBackgroundColor : lightBackgroundColor,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: const CustomNumpad(),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: iconColor),
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

    if (isCrypto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CurrencyRow(
            currencyCode: settings.baseCrypto,
            amount: amounts[settings.baseCrypto] ?? 0,
            isDarkMode: isDark,
            onTap: () => AssetPicker.showCrypto(
              context,
              ref,
              currentId: settings.baseCrypto,
              onSelected: (v) =>
                  ref.read(settingsProvider.notifier).setBaseCrypto(v),
              isDarkMode: isDark,
              searchHint: AppLocalizations.of(context)!.searchCrypto,
            ),
          ),
          _SwapButton(
            isDarkMode: isDark,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .swapBaseCryptoWithRow2Crypto(),
          ),
          if (settings.isRow2Visible)
            CurrencyRow(
              currencyCode: settings.row2Crypto,
              amount: amounts[settings.row2Crypto] ?? 0,
              isDarkMode: isDark,
              onTap: () => AssetPicker.showCrypto(
                context,
                ref,
                currentId: settings.row2Crypto,
                onSelected: (v) =>
                    ref.read(settingsProvider.notifier).setRow2Crypto(v),
                isDarkMode: isDark,
                searchHint: AppLocalizations.of(context)!.searchCrypto,
              ),
            ),
          if (settings.isRow3Visible)
            CurrencyRow(
              currencyCode: settings.row3Crypto,
              amount: amounts[settings.row3Crypto] ?? 0,
              isDarkMode: isDark,
              onTap: () => AssetPicker.showCrypto(
                context,
                ref,
                currentId: settings.row3Crypto,
                onSelected: (v) =>
                    ref.read(settingsProvider.notifier).setRow3Crypto(v),
                isDarkMode: isDark,
                searchHint: AppLocalizations.of(context)!.searchCrypto,
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CurrencyRow(
          currencyCode: settings.baseCurrency,
          amount: amounts[settings.baseCurrency] ?? 0,
          isDarkMode: isDark,
          onTap: () => AssetPicker.showFiat(
            context,
            currentId: settings.baseCurrency,
            onSelected: (v) =>
                ref.read(settingsProvider.notifier).setBaseCurrency(v),
            isDarkMode: isDark,
            searchHint: AppLocalizations.of(context)!.searchCurrency,
          ),
        ),
        _SwapButton(
          isDarkMode: isDark,
          onTap: () => ref.read(settingsProvider.notifier).swapBaseWithRow2(),
        ),
        if (settings.isRow2Visible)
          CurrencyRow(
            currencyCode: settings.row2Currency,
            amount: amounts[settings.row2Currency] ?? 0,
            isDarkMode: isDark,
            onTap: () => AssetPicker.showFiat(
              context,
              currentId: settings.row2Currency,
              onSelected: (v) =>
                  ref.read(settingsProvider.notifier).setRow2Currency(v),
              isDarkMode: isDark,
              searchHint: AppLocalizations.of(context)!.searchCurrency,
            ),
          ),
        if (settings.isRow3Visible)
          CurrencyRow(
            currencyCode: settings.row3Currency,
            amount: amounts[settings.row3Currency] ?? 0,
            isDarkMode: isDark,
            onTap: () => AssetPicker.showFiat(
              context,
              currentId: settings.row3Currency,
              onSelected: (v) =>
                  ref.read(settingsProvider.notifier).setRow3Currency(v),
              isDarkMode: isDark,
              searchHint: AppLocalizations.of(context)!.searchCurrency,
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
    final accent = isDarkMode ? accentColor : lightAccentColor;
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = accent.withValues(alpha: isDarkMode ? 0.5 : 0.35);
    final glowShadows = isDarkMode
        ? [
            BoxShadow(
              color: accent.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ]
        : <BoxShadow>[];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
                boxShadow: glowShadows,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.swap_vert_rounded, size: 28, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
