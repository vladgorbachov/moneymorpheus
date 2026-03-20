import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../core/constants.dart';
import '../data/models/crypto_kline.dart';
import '../data/models/crypto_ticker.dart';
import '../providers/crypto_provider.dart';
import '../providers/favourites_provider.dart';

/// Light theme: replaces white body text on crypto detail.
const _lightCryptoPrimary = Color(0xFF043536);

/// Light theme: replaces gray / muted labels.
const _lightCryptoSecondary = Color(0xFF005B63);

const _positiveColor = Color(0xFF2EB872);
const _negativeColor = Color(0xFFFF5A5A);
const _favouriteColor = Color(0xFFFFD700);
const _secondaryColor = Color(0xFFB9BDD2);
const _intervals = ['15m', '1h', '4h', '1d', '1w'];
const _binanceIntervals = ['15m', '1h', '4h', '1d', '1w'];

class CryptoDetailScreen extends ConsumerStatefulWidget {
  final String symbol;
  final bool isDarkMode;

  const CryptoDetailScreen({
    super.key,
    required this.symbol,
    required this.isDarkMode,
  });

  @override
  ConsumerState<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends ConsumerState<CryptoDetailScreen> {
  int _selectedIntervalIndex = 2;

  @override
  Widget build(BuildContext context) {
    final tickerAsync = ref.watch(cryptoTickerBySymbolProvider(widget.symbol));
    final interval = _binanceIntervals[_selectedIntervalIndex];
    final klinesAsync = ref.watch(
      cryptoKlinesProvider((symbol: widget.symbol, interval: interval)),
    );
    final favouritesAsync = ref.watch(favouritesProvider);
    final isFavourite = switch (favouritesAsync) {
      AsyncData(:final value) => value.contains(widget.symbol),
      _ => false,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: converterScreenDecoration(widget.isDarkMode),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _GlassIconButton(
                      isDarkMode: widget.isDarkMode,
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.symbol}/USDT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : _lightCryptoPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                          fontFamily: 'DejaVuSans',
                        ),
                      ),
                    ),
                    _GlassIconButton(
                      isDarkMode: widget.isDarkMode,
                      icon: isFavourite ? Icons.star_rounded : Icons.star_border_rounded,
                      iconColor: isFavourite
                          ? _favouriteColor
                          : (widget.isDarkMode ? _secondaryColor : _lightCryptoSecondary),
                      onTap: () => ref.read(favouritesProvider.notifier).toggle(widget.symbol),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                tickerAsync.when(
                  data: (ticker) => ticker != null
                      ? _PriceSection(ticker: ticker, isDarkMode: widget.isDarkMode)
                      : const SizedBox.shrink(),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: _favouriteColor)),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(e.toString(), style: const TextStyle(color: _negativeColor, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 18),
                _TimeframeBar(
                  selectedIndex: _selectedIntervalIndex,
                  isDarkMode: widget.isDarkMode,
                  onSelected: (i) => setState(() => _selectedIntervalIndex = i),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 392,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: widget.isDarkMode ? 0.06 : 0.16),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: klinesAsync.when(
                      data: (klines) => klines.isEmpty
                          ? Center(
                              child: Text(
                                'No chart data',
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? _secondaryColor.withValues(alpha: 0.9)
                                      : _lightCryptoSecondary,
                                ),
                              ),
                            )
                          : _CandlestickChart(
                              klines: klines,
                              isDarkMode: widget.isDarkMode,
                            ),
                      loading: () => const Center(child: CircularProgressIndicator(color: _favouriteColor)),
                      error: (e, _) => Center(
                        child: Text(
                          e.toString(),
                          style: const TextStyle(color: _negativeColor, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final bool isDarkMode;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.isDarkMode,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
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
            onTap: onTap,
            child: Icon(
              icon,
              color: iconColor ??
                  (isDarkMode ? Colors.white : _lightCryptoPrimary),
              size: 27,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  final CryptoTicker ticker;
  final bool isDarkMode;

  const _PriceSection({required this.ticker, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.change24h >= 0;
    final isStable = ticker.baseSymbol == 'USDT' || ticker.change24h == 0;
    final changeColor = isStable
        ? (isDarkMode ? _secondaryColor : _lightCryptoSecondary)
        : (isPositive ? _positiveColor : _negativeColor);
    final priceColor = isDarkMode ? Colors.white : _lightCryptoPrimary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${_formatPrice(ticker.price)}',
            style: TextStyle(
              color: priceColor,
              fontWeight: FontWeight.bold,
              fontSize: 41,
              fontFamily: kLarazFontFamily,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${ticker.change24h >= 0 ? '+' : ''}${ticker.change24h.toStringAsFixed(2)}%',
            style: TextStyle(
              color: changeColor,
              fontSize: 19,
              fontWeight: FontWeight.w600,
              fontFamily: kLarazFontFamily,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: '24h High',
                  value: _formatPrice(ticker.high24h),
                  isDarkMode: isDarkMode,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: '24h Low',
                  value: _formatPrice(ticker.low24h),
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: '24h Vol (${ticker.baseSymbol})',
                  value: _formatVolume(ticker.volume),
                  isDarkMode: isDarkMode,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: '24h Vol (USDT)',
                  value: _formatVolume(ticker.quoteVolume24h),
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double p) {
    if (p >= 1000) return p.toStringAsFixed(2);
    if (p >= 1) return p.toStringAsFixed(4);
    if (p >= 0.0001) return p.toStringAsFixed(6);
    return p.toStringAsFixed(8);
  }

  String _formatVolume(double v) {
    if (v >= 1e12) return '${(v / 1e12).toStringAsFixed(2)}T';
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDarkMode;

  const _StatItem({
    required this.label,
    required this.value,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDarkMode ? _secondaryColor : _lightCryptoSecondary;
    final valueColor = isDarkMode ? Colors.white : _lightCryptoPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: labelColor, fontSize: 14, fontFamily: 'DejaVuSans'),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: kLarazFontFamily,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TimeframeBar extends StatelessWidget {
  final int selectedIndex;
  final bool isDarkMode;
  final void Function(int) onSelected;

  const _TimeframeBar({required this.selectedIndex, required this.onSelected, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        _intervals.length,
        (i) => Padding(
          padding: EdgeInsets.only(right: i == _intervals.length - 1 ? 0 : 10),
          child: SizedBox(
            width: 58,
            height: 42,
            child: DecoratedBox(
              decoration: glassButtonDecoration(
                isDarkMode: isDarkMode,
                borderRadius: BorderRadius.circular(14),
                highlight: selectedIndex == i,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelected(i),
                  child: Center(
                    child: Text(
                      _intervals[i],
                      style: TextStyle(
                        color: !isDarkMode
                            ? (selectedIndex == i
                                ? _lightCryptoPrimary
                                : _lightCryptoSecondary)
                            : (selectedIndex == i ? Colors.white : _secondaryColor),
                        fontSize: 15,
                        fontWeight: selectedIndex == i ? FontWeight.w700 : FontWeight.w500,
                        fontFamily: kLarazFontFamily,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CandlestickChart extends StatelessWidget {
  final List<CryptoKline> klines;
  final bool isDarkMode;

  const _CandlestickChart({required this.klines, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final gridColor = isDarkMode ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08);
    final axisColor =
        isDarkMode ? _secondaryColor : _lightCryptoSecondary;

    return SfCartesianChart(
      margin: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(color: gridColor),
        axisLine: AxisLine(color: gridColor),
        labelStyle: TextStyle(color: axisColor, fontSize: 11, fontFamily: 'DejaVuSans'),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(color: gridColor),
        axisLine: AxisLine(color: gridColor),
        labelStyle: TextStyle(color: axisColor, fontSize: 11, fontFamily: 'DejaVuSans'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        zoomMode: ZoomMode.x,
      ),
      series: <CartesianSeries<CryptoKline, DateTime>>[
        CandleSeries<CryptoKline, DateTime>(
          dataSource: klines,
          xValueMapper: (k, _) => k.timestamp,
          lowValueMapper: (k, _) => k.low,
          highValueMapper: (k, _) => k.high,
          openValueMapper: (k, _) => k.open,
          closeValueMapper: (k, _) => k.close,
          bullColor: _positiveColor,
          bearColor: _negativeColor,
        ),
      ],
    );
  }
}
