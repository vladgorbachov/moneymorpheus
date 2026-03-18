import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/animated_background.dart';
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
        final bgColor = isDark ? darkBackgroundColor : lightBackgroundColor;
        final iconColor = isDark
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.85);

        return Scaffold(
          backgroundColor: bgColor,
          body: AnimatedBackground(
            isDarkMode: isDark,
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, iconColor),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          _buildDisplayArea(context, ref, settings, amounts),
                          const SizedBox(height: 24),
                          const CustomNumpad(),
                        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: iconColor),
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
