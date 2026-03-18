import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/calculator_provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../providers/settings_provider.dart';
import 'numpad_button.dart';

class CustomNumpad extends ConsumerWidget {
  const CustomNumpad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.read(calculatorProvider.notifier);
    final settingsAsync = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return settingsAsync.when(
      data: (settings) => _buildNumpad(
        context,
        ref,
        calculator,
        settings,
        l10n,
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
      childAspectRatio: 1.1,
      children: [
        NumpadButton(label: l10n.ac, onTap: () => calculator.clear()),
        NumpadButton(label: l10n.backspace, onTap: () => calculator.backspace()),
        NumpadButton(
          label: l10n.swap,
          onTap: () async {
            await ref.read(settingsProvider.notifier).swapBaseWithRow2();
          },
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
        _ShareButton(l10n: l10n),
      ],
    );
  }
}

class _ShareButton extends ConsumerWidget {
  final AppLocalizations l10n;

  const _ShareButton({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NumpadButton(
      label: l10n.share,
      onTap: () => _shareConversion(context, ref),
      isWide: true,
    );
  }

  Future<void> _shareConversion(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider).value ?? const SettingsState();
    final amounts = ref.read(convertedAmountsProvider);

    if (amounts.isEmpty) return;

    final base = settings.baseCurrency;
    final baseAmount = amounts[base] ?? 0;
    final parts = <String>['Moneymorpheus conversion: $baseAmount $base'];

    if (settings.isRow2Visible) {
      final row2Amount = amounts[settings.row2Currency];
      if (row2Amount != null) {
        parts.add(' = ${row2Amount.toStringAsFixed(2)} ${settings.row2Currency}');
      }
    }
    if (settings.isRow3Visible) {
      final row3Amount = amounts[settings.row3Currency];
      if (row3Amount != null) {
        parts.add(' = ${row3Amount.toStringAsFixed(2)} ${settings.row3Currency}');
      }
    }

    final dateStr = DateTime.now().toIso8601String().split('T').first;
    final text = '${parts.join()}. Rate as of $dateStr';

    try {
      await Share.share(text);
    } catch (_) {}
  }
}
