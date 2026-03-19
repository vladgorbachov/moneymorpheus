import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/currency_picker_sheet.dart';
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
                                    context, ref, settings, amounts),
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
                    color: isDark
                        ? darkBackgroundColor
                        : lightBackgroundColor,
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
  ) {
    final isDark = settings.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CurrencyRow(
          currencyCode: settings.baseCurrency,
          amount: amounts[settings.baseCurrency] ?? 0,
          isDarkMode: isDark,
          onTap: () => CurrencyPickerSheet.show(
            context,
            target: CurrencyPickerTarget.base,
            currentCurrency: settings.baseCurrency,
            onSelected: (v) =>
                ref.read(settingsProvider.notifier).setBaseCurrency(v),
            isDarkMode: isDark,
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
            onTap: () => CurrencyPickerSheet.show(
              context,
              target: CurrencyPickerTarget.row2,
              currentCurrency: settings.row2Currency,
              onSelected: (v) =>
                  ref.read(settingsProvider.notifier).setRow2Currency(v),
              isDarkMode: isDark,
            ),
          ),
        if (settings.isRow3Visible)
          CurrencyRow(
            currencyCode: settings.row3Currency,
            amount: amounts[settings.row3Currency] ?? 0,
            isDarkMode: isDark,
            onTap: () => CurrencyPickerSheet.show(
              context,
              target: CurrencyPickerTarget.row3,
              currentCurrency: settings.row3Currency,
              onSelected: (v) =>
                  ref.read(settingsProvider.notifier).setRow3Currency(v),
              isDarkMode: isDark,
            ),
          ),
      ],
    );
  }
}

class _SwapButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTap;

  const _SwapButton({
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDarkMode ? accentColor : lightAccentColor;
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Material(
          color: accent.withValues(alpha: 0.4),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                Icons.swap_vert_rounded,
                size: 28,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
