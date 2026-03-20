import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../providers/calculator_provider.dart';
import '../providers/converter_mode_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/crypto_market_screen.dart';
import 'bitcoin_badge.dart';
import 'numpad_button.dart';

class CustomNumpad extends ConsumerWidget {
  const CustomNumpad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.read(calculatorProvider.notifier);
    final settingsAsync = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return settingsAsync.when(
      data: (settings) => _buildNumpad(context, ref, calculator, settings, l10n),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        const padT = 10.0;
        const padB = 8.0;
        final innerH =
            (constraints.maxHeight - padT - padB).clamp(0.0, double.infinity);
        final topHeight = ((innerH - spacing * 4) * 0.14).clamp(48.0, 76.0);
        final standardHeight =
            ((innerH - spacing * 4 - topHeight) / 4).clamp(44.0, 110.0);

        Widget row(List<Widget> children, double height) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  Expanded(child: children[i]),
                  if (i != children.length - 1) const SizedBox(width: spacing),
                ],
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(8, padT, 8, padB),
          color: Colors.transparent,
          child: Column(
            children: [
              row([
                NumpadButton(
                  label: l10n.ac,
                  compactTopRow: true,
                  fontSize: 27,
                  flatConverterStyle: true,
                  converterTone: ConverterKeyTone.clear,
                  onTap: calculator.clear,
                ),
                _CryptoButton(l10n: l10n),
                NumpadButton(
                  label: l10n.backspace,
                  compactTopRow: true,
                  fontSize: 23,
                  flatConverterStyle: true,
                  converterTone: ConverterKeyTone.auxiliary,
                  onTap: calculator.backspace,
                ),
              ], topHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(
                  label: '1',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('1'),
                ),
                NumpadButton(
                  label: '2',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('2'),
                ),
                NumpadButton(
                  label: '3',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('3'),
                ),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(
                  label: '4',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('4'),
                ),
                NumpadButton(
                  label: '5',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('5'),
                ),
                NumpadButton(
                  label: '6',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('6'),
                ),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(
                  label: '7',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('7'),
                ),
                NumpadButton(
                  label: '8',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('8'),
                ),
                NumpadButton(
                  label: '9',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('9'),
                ),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                const _BtcModeButton(),
                NumpadButton(
                  label: '0',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('0'),
                ),
                NumpadButton(
                  label: '.',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('.'),
                ),
              ], standardHeight),
            ],
          ),
        );
      },
    );
  }
}

class _BtcModeButton extends ConsumerWidget {
  const _BtcModeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NumpadButton(
      flatConverterStyle: true,
      converterTone: ConverterKeyTone.digit,
      onTap: () => ref.read(converterModeProvider.notifier).toggle(),
      child: const Center(child: BitcoinBadge(size: 34)),
    );
  }
}

class _CryptoButton extends ConsumerWidget {
  final AppLocalizations l10n;

  const _CryptoButton({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NumpadButton(
      label: 'CRYPTO',
      compactTopRow: true,
      fontSize: 18,
      flatConverterStyle: true,
      converterTone: ConverterKeyTone.auxiliary,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const CryptoMarketScreen()),
      ),
    );
  }
}
