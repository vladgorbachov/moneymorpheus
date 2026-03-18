import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/animated_background.dart';
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

    return Scaffold(
      backgroundColor: baseBackgroundColor,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      settingsAsync.when(
                        data: (settings) => _buildDisplayArea(
                          context,
                          settings,
                          amounts,
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Error: $e',
                            style: TextStyle(color: Colors.red.shade300),
                          ),
                        ),
                      ),
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
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white.withOpacity(0.9),
            ),
            onPressed: () => SettingsSheet.show(context),
          ),
          const MicrophoneButton(),
        ],
      ),
    );
  }

  Widget _buildDisplayArea(
    BuildContext context,
    SettingsState settings,
    Map<String, double> amounts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CurrencyRow(
          currencyCode: settings.baseCurrency,
          amount: amounts[settings.baseCurrency] ?? 0,
        ),
        if (settings.isRow2Visible)
          CurrencyRow(
            currencyCode: settings.row2Currency,
            amount: amounts[settings.row2Currency] ?? 0,
          ),
        if (settings.isRow3Visible)
          CurrencyRow(
            currencyCode: settings.row3Currency,
            amount: amounts[settings.row3Currency] ?? 0,
          ),
      ],
    );
  }
}
