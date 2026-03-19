import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/crypto_market_screen.dart';
import 'numpad_button.dart';

class CustomNumpad extends ConsumerWidget {
  const CustomNumpad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.read(calculatorProvider.notifier);
    final settingsAsync = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return settingsAsync.when(
      data: (settings) =>
          _buildNumpad(context, ref, calculator, settings, l10n),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildNumpad(
    BuildContext context,
    WidgetRef ref,
    CalculatorNotifier calculator,
    SettingsState settings,
    AppLocalizations l10n,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.85,
      children: [
        NumpadButton(label: l10n.ac, onTap: () => calculator.clear()),
        NumpadButton(
          label: l10n.backspace,
          onTap: () => calculator.backspace(),
        ),
        NumpadButton(label: '1', onTap: () => calculator.appendDigit('1')),
        NumpadButton(label: '2', onTap: () => calculator.appendDigit('2')),
        NumpadButton(label: '3', onTap: () => calculator.appendDigit('3')),
        NumpadButton(label: '4', onTap: () => calculator.appendDigit('4')),
        NumpadButton(label: '5', onTap: () => calculator.appendDigit('5')),
        NumpadButton(label: '6', onTap: () => calculator.appendDigit('6')),
        NumpadButton(label: '7', onTap: () => calculator.appendDigit('7')),
        NumpadButton(label: '8', onTap: () => calculator.appendDigit('8')),
        NumpadButton(label: '9', onTap: () => calculator.appendDigit('9')),
        NumpadButton(label: '.', onTap: () => calculator.appendDigit('.')),
        NumpadButton(label: '0', onTap: () => calculator.appendDigit('0')),
        _CryptoButton(l10n: l10n),
        const SizedBox.shrink(),
      ],
    );
  }
}

class _CryptoButton extends ConsumerWidget {
  final AppLocalizations l10n;

  const _CryptoButton({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NumpadButton(
      label: l10n.crypto,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const CryptoMarketScreen()),
      ),
      isWide: true,
    );
  }
}
