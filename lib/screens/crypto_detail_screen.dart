import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../core/constants.dart';
import '../data/models/crypto_kline.dart';
import '../providers/crypto_provider.dart';

const _intervals = ['1h', '4h', '1d'];
const _binanceIntervals = ['1h', '4h', '1d'];

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
  int _selectedIntervalIndex = 0;

  @override
  Widget build(BuildContext context) {
    final interval = _binanceIntervals[_selectedIntervalIndex];
    final klinesAsync = ref.watch(
      cryptoKlinesProvider((symbol: widget.symbol, interval: interval)),
    );
    final surfaceColor = widget.isDarkMode
        ? darkBackgroundColor
        : lightBackgroundColor;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.symbol}/USDT',
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
            child: Row(
              children: List.generate(
                _intervals.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_intervals[i]),
                    selected: _selectedIntervalIndex == i,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedIntervalIndex = i);
                      }
                    },
                    selectedColor: accentColor.withValues(alpha: 0.5),
                    labelStyle: TextStyle(
                      color: _selectedIntervalIndex == i
                          ? Colors.white
                          : textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: klinesAsync.when(
              data: (klines) => _CandlestickChart(
                klines: klines,
                isDarkMode: widget.isDarkMode,
              ),
              loading: () =>
                  Center(child: CircularProgressIndicator(color: accentColor)),
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
    );
  }
}

class _CandlestickChart extends StatelessWidget {
  final List<CryptoKline> klines;
  final bool isDarkMode;

  const _CandlestickChart({required this.klines, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final bullishColor = Colors.green;
    final bearishColor = Colors.red;
    final gridColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    final axisColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.7);

    return SfCartesianChart(
      margin: const EdgeInsets.all(16),
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(color: gridColor),
        axisLine: AxisLine(color: axisColor),
        labelStyle: TextStyle(color: axisColor, fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(color: gridColor),
        axisLine: AxisLine(color: axisColor),
        labelStyle: TextStyle(color: axisColor, fontSize: 10),
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
          bullColor: bullishColor,
          bearColor: bearishColor,
        ),
      ],
    );
  }
}
