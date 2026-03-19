import 'dart:ui';

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

const _positiveColor = Color(0xFF2EB872);
const _negativeColor = Color(0xFFFF5A5A);
const _favouriteColor = Color(0xFFFFD700);
const _secondaryTextColor = Color(0xFFB9BDD2);

class CryptoMarketScreen extends ConsumerWidget {
  const CryptoMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return settingsAsync.when(
      data: (settings) => _CryptoMarketContent(isDarkMode: settings.isDarkMode, l10n: l10n),
      loading: () => Scaffold(
        body: Container(
          decoration: buildThemedWallpaper(true),
          child: Center(child: CircularProgressIndicator(color: _favouriteColor)),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Container(
          decoration: buildThemedWallpaper(true),
          child: Center(child: Text('Error: $e', style: const TextStyle(color: _negativeColor))),
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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: buildThemedWallpaper(isDarkMode),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 60,
                      child: DecoratedBox(
                        decoration: glassButtonDecoration(
                          isDarkMode: isDarkMode,
                          borderRadius: BorderRadius.circular(18),
                          highlight: true,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                l10n.close,
                                style: TextStyle(
                                  fontFamily: 'Merriweather',
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.96),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'CRYPTO',
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.96),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 120),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: TextField(
                      onChanged: (v) => ref.read(cryptoSearchQueryProvider.notifier).updateQuery(v),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'DejaVuSans',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchCrypto,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontFamily: 'DejaVuSans',
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.65)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: isDarkMode ? 0.08 : 0.16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: (isDarkMode ? accentColor : lightAccentColor).withValues(alpha: 0.52)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: tickersAsync.when(
                  data: (tickers) => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
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
                        onStarTap: () => ref.read(favouritesProvider.notifier).toggle(ticker.baseSymbol),
                        isFavourite: switch (ref.watch(favouritesProvider)) {
                          AsyncData(:final value) => value.contains(ticker.baseSymbol),
                          _ => false,
                        },
                      );
                    },
                  ),
                  loading: () => Center(child: CircularProgressIndicator(color: _favouriteColor)),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _negativeColor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TickerRow extends StatelessWidget {
  final CryptoTicker ticker;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onStarTap;
  final bool isFavourite;

  const _TickerRow({
    required this.ticker,
    required this.isDarkMode,
    required this.onTap,
    required this.onStarTap,
    required this.isFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.change24h >= 0;
    final isStable = ticker.baseSymbol == 'USDT' || ticker.change24h == 0;
    final priceColor = isStable ? Colors.white : (isPositive ? _positiveColor : _negativeColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDarkMode ? 0.06 : 0.16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  CryptoLogo(symbol: ticker.baseSymbol, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticker.baseSymbol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            fontFamily: 'DejaVuSans',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cryptoDisplayName(ticker.baseSymbol),
                          style: TextStyle(
                            color: _secondaryTextColor.withValues(alpha: 0.95),
                            fontSize: 13,
                            fontFamily: 'DejaVuSans',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatPrice(ticker.price),
                          style: TextStyle(
                            color: priceColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            fontFamily: 'Metropolis',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatVolume(ticker.volume),
                          style: const TextStyle(
                            color: _secondaryTextColor,
                            fontSize: 12,
                            fontFamily: 'DejaVuSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onStarTap,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      isFavourite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFavourite ? _favouriteColor : _secondaryTextColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
