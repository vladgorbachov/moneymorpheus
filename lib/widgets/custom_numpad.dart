import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import 'numpad_button.dart';

class _NumpadPlaceholder extends StatelessWidget {
  const _NumpadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class CustomNumpad extends ConsumerWidget {
  const CustomNumpad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.read(calculatorProvider.notifier);
    final settingsAsync = ref.watch(settingsProvider);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        NumpadButton(label: '7', onTap: () => calculator.appendDigit('7')),
        NumpadButton(label: '8', onTap: () => calculator.appendDigit('8')),
        NumpadButton(label: '9', onTap: () => calculator.appendDigit('9')),
        NumpadButton(
          label: '⌫',
          onTap: () => calculator.backspace(),
        ),
        NumpadButton(label: '4', onTap: () => calculator.appendDigit('4')),
        NumpadButton(label: '5', onTap: () => calculator.appendDigit('5')),
        NumpadButton(label: '6', onTap: () => calculator.appendDigit('6')),
        NumpadButton(label: 'AC', onTap: () => calculator.clear()),
        NumpadButton(label: '1', onTap: () => calculator.appendDigit('1')),
        NumpadButton(label: '2', onTap: () => calculator.appendDigit('2')),
        NumpadButton(label: '3', onTap: () => calculator.appendDigit('3')),
        NumpadButton(
          label: '⇄',
          onTap: () async {
            final settings = settingsAsync.valueOrNull;
            if (settings != null) {
              await ref.read(settingsProvider.notifier).swapBaseWithRow2();
            }
          },
          isWide: true,
        ),
        NumpadButton(
          label: '0',
          onTap: () => calculator.appendDigit('0'),
        ),
        NumpadButton(label: '.', onTap: () => calculator.appendDigit('.')),
        const _NumpadPlaceholder(),
        const _NumpadPlaceholder(),
      ],
    );
  }
}
