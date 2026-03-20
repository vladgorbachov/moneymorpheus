import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxly/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../providers/calculator_provider.dart';
import '../providers/converter_mode_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/asset_picker.dart';
import '../widgets/currency_row.dart';
import '../widgets/custom_numpad.dart';
import '../widgets/settings_sheet.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey _currencyPanelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
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
        final appBarIconColor =
            isDark ? Colors.white : refLightKeypadTeal;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: DecoratedBox(
              decoration: converterScreenDecoration(isDark),
              child: Column(
                children: [
                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildAppBar(context, appBarIconColor),
                          const SizedBox(height: 8),
                          Expanded(
                            child:                           _buildDisplayArea(
                              context,
                              ref,
                              settings,
                              amounts,
                              mode,
                              appBarIconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      child: const CustomNumpad(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: refDarkGradientTop,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
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

  Widget _buildAppBar(BuildContext context, Color appBarIconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: Icon(Icons.menu_rounded, color: appBarIconColor, size: 29),
          onPressed: () {
            final box =
                _currencyPanelKey.currentContext?.findRenderObject() as RenderBox?;
            final top = box?.localToGlobal(Offset.zero).dy;
            SettingsSheet.show(context, currencyPanelTop: top);
          },
        ),
      ),
    );
  }

  Widget _buildDisplayArea(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    Map<String, double> amounts,
    ConverterMode? mode,
    Color onGradientIconColor,
  ) {
    final isCrypto = mode == ConverterMode.crypto;
    final calc = ref.watch(calculatorProvider);

    final rows = <Widget>[
      Expanded(
        child: CurrencyRow(
          currencyCode: isCrypto ? settings.baseCrypto : settings.baseCurrency,
          amount: amounts[isCrypto ? settings.baseCrypto : settings.baseCurrency] ?? 0,
          inputOverride: calc.inputString,
          onTap: () => isCrypto
              ? AssetPicker.showCrypto(
                  context,
                  ref,
                  currentId: settings.baseCrypto,
                  onSelected: (v) => ref.read(settingsProvider.notifier).setBaseCrypto(v),
                  isDarkMode: settings.isDarkMode,
                  searchHint: AppLocalizations.of(context)!.searchCrypto,
                )
              : AssetPicker.showFiat(
                  context,
                  currentId: settings.baseCurrency,
                  onSelected: (v) => ref.read(settingsProvider.notifier).setBaseCurrency(v),
                  isDarkMode: settings.isDarkMode,
                  searchHint: AppLocalizations.of(context)!.searchCurrency,
                ),
        ),
      ),
      if (settings.isRow2Visible)
        Expanded(
          child: CurrencyRow(
            currencyCode: settings.row2Currency,
            amount: amounts[settings.row2Currency] ?? 0,
            onTap: () => AssetPicker.showFiat(
              context,
              currentId: settings.row2Currency,
              onSelected: (v) =>
                  ref.read(settingsProvider.notifier).setRow2Currency(v),
              isDarkMode: settings.isDarkMode,
              searchHint: AppLocalizations.of(context)!.searchCurrency,
            ),
          ),
        ),
      if (settings.isRow3Visible)
        Expanded(
          child: CurrencyRow(
            currencyCode: settings.row3Currency,
            amount: amounts[settings.row3Currency] ?? 0,
            onTap: () => AssetPicker.showFiat(
              context,
              currentId: settings.row3Currency,
              onSelected: (v) =>
                  ref.read(settingsProvider.notifier).setRow3Currency(v),
              isDarkMode: settings.isDarkMode,
              searchHint: AppLocalizations.of(context)!.searchCurrency,
            ),
          ),
        ),
    ];

    final visibleCount = rows.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final swapTop = visibleCount >= 2 ? (h / visibleCount) - 22 : 0.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            KeyedSubtree(
              key: _currencyPanelKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              ),
            ),
            if (settings.isRow2Visible && visibleCount >= 2)
              Positioned(
                top: swapTop,
                left: 0,
                child: _SwapButton(
                  iconColor: onGradientIconColor,
                  onTap: () => isCrypto
                      ? ref
                          .read(settingsProvider.notifier)
                          .swapBaseCryptoWithRow2Crypto()
                      : ref.read(settingsProvider.notifier).swapBaseWithRow2(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SwapButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;

  const _SwapButton({required this.onTap, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.swap_vert_rounded, size: 33, color: iconColor),
        ),
      ),
    );
  }
}
