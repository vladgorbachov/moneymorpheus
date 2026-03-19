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
    final isDark = settings.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final buttonWidth = (constraints.maxWidth - spacing * 2) / 3;
        final topHeight = ((constraints.maxHeight - spacing * 4) * 0.14)
            .clamp(58.0, 82.0);
        final standardHeight = ((constraints.maxHeight - spacing * 4 - topHeight) / 4)
            .clamp(74.0, 118.0);

        Widget row(List<Widget> children, double height) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  SizedBox(width: buttonWidth, child: children[i]),
                  if (i != children.length - 1) const SizedBox(width: spacing),
                ],
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.18),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.38),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? accentColor : lightAccentColor).withValues(alpha: isDark ? 0.18 : 0.10),
                blurRadius: 26,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              row([
                NumpadButton(
                  label: l10n.ac,
                  compactTopRow: true,
                  fontSize: 28,
                  onTap: calculator.clear,
                ),
                _CryptoButton(l10n: l10n),
                NumpadButton(
                  label: l10n.backspace,
                  compactTopRow: true,
                  fontSize: 22,
                  onTap: calculator.backspace,
                ),
              ], topHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(label: '1', onTap: () => calculator.appendDigit('1')),
                NumpadButton(label: '2', onTap: () => calculator.appendDigit('2')),
                NumpadButton(label: '3', onTap: () => calculator.appendDigit('3')),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(label: '4', onTap: () => calculator.appendDigit('4')),
                NumpadButton(label: '5', onTap: () => calculator.appendDigit('5')),
                NumpadButton(label: '6', onTap: () => calculator.appendDigit('6')),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(label: '7', onTap: () => calculator.appendDigit('7')),
                NumpadButton(label: '8', onTap: () => calculator.appendDigit('8')),
                NumpadButton(label: '9', onTap: () => calculator.appendDigit('9')),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                _BtcModeButton(),
                NumpadButton(label: '0', onTap: () => calculator.appendDigit('0')),
                NumpadButton(label: '.', onTap: () => calculator.appendDigit('.')),
              ], standardHeight),
            ],
          ),
        );
      },
    );
  }
}

class _BtcModeButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NumpadButton(
      glassHighlight: true,
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
      fontSize: 19.5,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const CryptoMarketScreen()),
      ),
    );
  }
}
