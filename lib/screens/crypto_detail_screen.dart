import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../data/models/crypto_kline.dart';
import '../data/models/crypto_ticker.dart';
import '../providers/crypto_provider.dart';
import '../providers/favourites_provider.dart';

const _bgColor = Color(0xFF0B1E33);
const _positiveColor = Color(0xFF2EB872);
const _negativeColor = Color(0xFFFF5A5A);
const _favouriteColor = Color(0xFFFFD700);
const _secondaryColor = Color(0xFF8E9AAF);
const _tabActiveColor = Color(0xFFFFD700);

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
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.symbol}/USDT',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavourite ? Icons.star : Icons.star_border,
              color: isFavourite ? _favouriteColor : _secondaryColor,
            ),
            onPressed: () =>
                ref.read(favouritesProvider.notifier).toggle(widget.symbol),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tickerAsync.when(
              data: (ticker) => ticker != null
                  ? _PriceSection(ticker: ticker)
                  : const SizedBox.shrink(),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: _favouriteColor),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  e.toString(),
                  style: TextStyle(color: _negativeColor, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _TimeframeBar(
              selectedIndex: _selectedIntervalIndex,
              onSelected: (i) => setState(() => _selectedIntervalIndex = i),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: klinesAsync.when(
                data: (klines) => klines.isEmpty
                    ? Center(
                        child: Text(
                          'No chart data',
                          style: TextStyle(color: _secondaryColor),
                        ),
                      )
                    : _CandlestickChart(
                        klines: klines,
                        isDarkMode: widget.isDarkMode,
                      ),
                loading: () => Center(
                  child: CircularProgressIndicator(color: _favouriteColor),
                ),
                error: (e, _) => Center(
                  child: Text(
                    e.toString(),
                    style: TextStyle(color: _negativeColor, fontSize: 12),
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

class _PriceSection extends StatelessWidget {
  final CryptoTicker ticker;

  const _PriceSection({required this.ticker});

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.change24h >= 0;
    final isStable = ticker.baseSymbol == 'USDT' || ticker.change24h == 0;
    final changeColor = isStable
        ? _secondaryColor
        : (isPositive ? _positiveColor : _negativeColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${_formatPrice(ticker.price)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${ticker.change24h >= 0 ? '+' : ''}${ticker.change24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: '24h High',
                  value: _formatPrice(ticker.high24h),
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: '24h Low',
                  value: _formatPrice(ticker.low24h),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: '24h Vol (${ticker.baseSymbol})',
                  value: _formatVolume(ticker.volume),
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: '24h Vol (USDT)',
                  value: _formatVolume(ticker.quoteVolume24h),
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

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _secondaryColor, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TimeframeBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelected;

  const _TimeframeBar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          _intervals.length,
          (i) => GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selectedIndex == i
                        ? _tabActiveColor
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                _intervals[i],
                style: TextStyle(
                  color: selectedIndex == i ? Colors.white : _secondaryColor,
                  fontSize: 14,
                  fontWeight: selectedIndex == i
                      ? FontWeight.w600
                      : FontWeight.normal,
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
    const gridColor = Color(0xFF1E3A4D);
    const axisColor = Color(0xFF8E9AAF);

    return SfCartesianChart(
      margin: const EdgeInsets.all(12),
      plotAreaBorderWidth: 0,
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(color: gridColor),
        axisLine: const AxisLine(color: gridColor),
        labelStyle: const TextStyle(color: axisColor, fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(color: gridColor),
        axisLine: const AxisLine(color: gridColor),
        labelStyle: const TextStyle(color: axisColor, fontSize: 10),
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
