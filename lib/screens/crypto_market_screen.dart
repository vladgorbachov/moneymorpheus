import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymorpheus/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../core/crypto_logos.dart';
import '../data/models/crypto_ticker.dart';
import '../providers/crypto_provider.dart';
import '../providers/favourites_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/crypto_logo.dart';
import 'crypto_detail_screen.dart';

const _cryptoMarketBg = Color(0xFF0B1E33);
const _positiveColor = Color(0xFF2EB872);
const _negativeColor = Color(0xFFFF5A5A);
const _favouriteColor = Color(0xFFFFD700);
const _secondaryTextColor = Color(0xFF8E9AAF);
const _searchBarBg = Color(0xFF152A3D);

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
        backgroundColor: _cryptoMarketBg,
        body: Center(child: CircularProgressIndicator(color: _favouriteColor)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _cryptoMarketBg,
        body: Center(
          child: Text('Error: $e', style: TextStyle(color: _negativeColor)),
        ),
      ),
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

    return Scaffold(
      backgroundColor: _cryptoMarketBg,
      appBar: AppBar(
        backgroundColor: _cryptoMarketBg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _CloseButton(l10n: l10n),
        ),
        title: Text(
          l10n.crypto,
          style: TextStyle(
            color: Colors.white,
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
                hintText: l10n.searchCrypto,
                hintStyle: TextStyle(color: _secondaryTextColor),
                prefixIcon: Icon(Icons.search, color: _secondaryTextColor),
                filled: true,
                fillColor: _searchBarBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: tickersAsync.when(
              data: (tickers) => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: tickers.length,
                itemBuilder: (context, index) {
                  final ticker = tickers[index];
                  return _TickerRow(
                    ticker: ticker,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CryptoDetailScreen(
                          symbol: ticker.baseSymbol,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ),
                    onStarTap: () => ref
                        .read(favouritesProvider.notifier)
                        .toggle(ticker.baseSymbol),
                    isFavourite: switch (ref.watch(favouritesProvider)) {
                      AsyncData(:final value) => value.contains(
                        ticker.baseSymbol,
                      ),
                      _ => false,
                    },
                  );
                },
              ),
              loading: () => Center(
                child: CircularProgressIndicator(color: _favouriteColor),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _negativeColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final AppLocalizations l10n;

  const _CloseButton({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          backgroundColor: accentColor.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(l10n.close),
      ),
    );
  }
}

class _TickerRow extends StatelessWidget {
  final CryptoTicker ticker;
  final VoidCallback onTap;
  final VoidCallback onStarTap;
  final bool isFavourite;

  const _TickerRow({
    required this.ticker,
    required this.onTap,
    required this.onStarTap,
    required this.isFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.change24h >= 0;
    final isStable = ticker.baseSymbol == 'USDT' || ticker.change24h == 0;
    final priceColor = isStable
        ? Colors.white
        : (isPositive ? _positiveColor : _negativeColor);
    final changeBgColor = isPositive ? _positiveColor : _negativeColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CryptoLogo(symbol: ticker.baseSymbol, size: 36),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cryptoDisplayName(ticker.baseSymbol),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ticker.baseSymbol,
                    style: TextStyle(color: _secondaryTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatPrice(ticker.price),
                    style: TextStyle(
                      color: priceColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatVolume(ticker.volume),
                    style: TextStyle(color: _secondaryTextColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: changeBgColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${ticker.change24h >= 0 ? '+' : ''}${ticker.change24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isStable ? _secondaryTextColor : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onStarTap,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                isFavourite ? Icons.star : Icons.star_border,
                color: isFavourite ? _favouriteColor : _secondaryTextColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) return '\$${price.toStringAsFixed(2)}';
    if (price >= 1) return '\$${price.toStringAsFixed(4)}';
    if (price >= 0.0001) return '\$${price.toStringAsFixed(6)}';
    return '\$${price.toStringAsFixed(8)}';
  }

  String _formatVolume(double vol) {
    if (vol >= 1e12) return '${(vol / 1e12).toStringAsFixed(2)}T';
    if (vol >= 1e9) return '${(vol / 1e9).toStringAsFixed(2)}B';
    if (vol >= 1e6) return '${(vol / 1e6).toStringAsFixed(2)}M';
    if (vol >= 1e3) return '${(vol / 1e3).toStringAsFixed(2)}K';
    return vol.toStringAsFixed(0);
  }
}
