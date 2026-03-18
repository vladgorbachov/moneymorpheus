import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../data/models/crypto_ticker.dart';
import '../providers/crypto_provider.dart';
import '../providers/settings_provider.dart';
import 'crypto_detail_screen.dart';

class CryptoMarketScreen extends ConsumerWidget {
  const CryptoMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return settingsAsync.when(
      data: (settings) =>
          _CryptoMarketContent(isDarkMode: settings.isDarkMode, l10n: l10n),
      loading: () => Scaffold(
        backgroundColor: darkBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _CryptoMarketContent extends ConsumerWidget {
  final bool isDarkMode;
  final AppLocalizations l10n;

  const _CryptoMarketContent({required this.isDarkMode, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickersAsync = ref.watch(cryptoFilteredTickersProvider);
    final theme = isDarkMode
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    final surfaceColor = isDarkMode
        ? darkBackgroundColor
        : lightBackgroundColor;
    final cardColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.9);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.6);

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: surfaceColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          title: Text(
            l10n.crypto,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (v) =>
                    ref.read(cryptoSearchQueryProvider.notifier).updateQuery(v),
                decoration: InputDecoration(
                  hintText: l10n.searchCurrency,
                  hintStyle: TextStyle(color: secondaryColor),
                  prefixIcon: Icon(Icons.search, color: secondaryColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(color: textColor),
              ),
            ),
            Expanded(
              child: tickersAsync.when(
                data: (tickers) => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tickers.length,
                  itemBuilder: (context, index) {
                    final ticker = tickers[index];
                    return _TickerRow(
                      ticker: ticker,
                      isDarkMode: isDarkMode,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => CryptoDetailScreen(
                            symbol: ticker.baseSymbol,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(color: accentColor),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TickerRow extends StatelessWidget {
  final CryptoTicker ticker;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _TickerRow({
    required this.ticker,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.change24h >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final cardColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.9);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                ticker.baseSymbol,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                _formatPrice(ticker.price),
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: isDarkMode ? 0.3 : 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${ticker.change24h >= 0 ? '+' : ''}${ticker.change24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    if (price >= 0.0001) return price.toStringAsFixed(6);
    return price.toStringAsFixed(8);
  }
}
