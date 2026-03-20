import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxly/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../providers/calculator_provider.dart';
import '../providers/converter_mode_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/crypto_market_screen.dart';
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
        const padT = 10.0;
        const padB = 8.0;
        final innerH =
            (constraints.maxHeight - padT - padB).clamp(0.0, double.infinity);
        final topHeight = ((innerH - spacing * 4) * 0.14).clamp(48.0, 76.0);
        final standardHeight =
            ((innerH - spacing * 4 - topHeight) / 4).clamp(44.0, 110.0);

        Widget row(List<Widget> children, double height) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  Expanded(child: children[i]),
                  if (i != children.length - 1) const SizedBox(width: spacing),
                ],
              ],
            ),
          );
        }

        final digitColor =
            isDark ? Colors.white : refLightKeypadTeal;

        return Container(
          padding: const EdgeInsets.fromLTRB(8, padT, 8, padB),
          color: Colors.transparent,
          child: Column(
            children: [
              row([
                NumpadButton(
                  label: l10n.ac,
                  compactTopRow: true,
                  fontSize: 27,
                  flatConverterStyle: true,
                  converterTone: ConverterKeyTone.digit,
                  onTap: calculator.clear,
                ),
                _CryptoNavButton(
                  topHeight: topHeight,
                  isDark: isDark,
                ),
                NumpadButton(
                  compactTopRow: true,
                  fontSize: 23,
                  flatConverterStyle: true,
                  converterTone: ConverterKeyTone.auxiliary,
                  onTap: calculator.backspace,
                  child: Icon(
                    Icons.backspace_outlined,
                    size: 26,
                    color: digitColor,
                  ),
                ),
              ], topHeight),
              SizedBox(
                height: 20,
                width: double.infinity,
                child: CustomPaint(
                  painter: _GlassFoldSeparatorPainter(isDark: isDark),
                ),
              ),
              const SizedBox(height: spacing),
              row([
                NumpadButton(
                  label: '1',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('1'),
                ),
                NumpadButton(
                  label: '2',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('2'),
                ),
                NumpadButton(
                  label: '3',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('3'),
                ),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(
                  label: '4',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('4'),
                ),
                NumpadButton(
                  label: '5',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('5'),
                ),
                NumpadButton(
                  label: '6',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('6'),
                ),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                NumpadButton(
                  label: '7',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('7'),
                ),
                NumpadButton(
                  label: '8',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('8'),
                ),
                NumpadButton(
                  label: '9',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('9'),
                ),
              ], standardHeight),
              const SizedBox(height: spacing),
              row([
                _ModeToggleButton(digitColor: digitColor),
                NumpadButton(
                  label: '0',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('0'),
                ),
                NumpadButton(
                  label: '.',
                  flatConverterStyle: true,
                  onTap: () => calculator.appendDigit('.'),
                ),
              ], standardHeight),
            ],
          ),
        );
      },
    );
  }
}

/// Fiat ↔ crypto mode: swap arrows, same tone as keypad digits.
class _ModeToggleButton extends ConsumerWidget {
  const _ModeToggleButton({required this.digitColor});

  final Color digitColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NumpadButton(
      flatConverterStyle: true,
      converterTone: ConverterKeyTone.digit,
      onTap: () => ref.read(converterModeProvider.notifier).toggle(),
      child: Icon(
        Icons.swap_horiz_rounded,
        size: 34,
        color: digitColor,
      ),
    );
  }
}

/// Rounded stadium: artwork fills the button at native aspect ratio (letterboxed).
class _CryptoNavButton extends ConsumerWidget {
  const _CryptoNavButton({
    required this.topHeight,
    required this.isDark,
  });

  final double topHeight;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = (topHeight * 0.82).clamp(40.0, 64.0);
    final glassBorder = Colors.white.withValues(alpha: isDark ? 0.42 : 0.48);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const CryptoMarketScreen()),
          ),
          child: Ink(
            height: h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: glassBorder, width: 1.25),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.32),
                  blurRadius: 5,
                  spreadRadius: -0.5,
                  offset: const Offset(-1, -1),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.12),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    isDark
                        ? 'assets/market_logo_dark.png'
                        : 'assets/market_logo_light.jpg',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
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

/// Glass-like fold line with a center dip (under the crypto nav pill).
class _GlassFoldSeparatorPainter extends CustomPainter {
  _GlassFoldSeparatorPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mid = w / 2;
    final yTop = h * 0.35;
    final yDip = h * 0.92;
    final dipHalfWidth = w * 0.16;
    final leftX = mid - dipHalfWidth;
    final rightX = mid + dipHalfWidth;

    final path = Path()
      ..moveTo(0, yTop)
      ..lineTo(leftX, yTop)
      ..cubicTo(
        leftX + dipHalfWidth * 0.35,
        yTop,
        mid - dipHalfWidth * 0.25,
        yDip,
        mid,
        yDip,
      )
      ..cubicTo(
        mid + dipHalfWidth * 0.25,
        yDip,
        rightX - dipHalfWidth * 0.35,
        yTop,
        rightX,
        yTop,
      )
      ..lineTo(w, yTop);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
          Colors.white.withValues(alpha: isDark ? 0.42 : 0.72),
          Colors.white.withValues(alpha: isDark ? 0.1 : 0.22),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, stroke);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: isDark ? 0.06 : 0.12)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3);
    canvas.drawPath(path, glow);

    final fill = Path()
      ..moveTo(0, yTop)
      ..lineTo(leftX, yTop)
      ..cubicTo(
        leftX + dipHalfWidth * 0.35,
        yTop,
        mid - dipHalfWidth * 0.25,
        yDip,
        mid,
        yDip,
      )
      ..cubicTo(
        mid + dipHalfWidth * 0.25,
        yDip,
        rightX - dipHalfWidth * 0.35,
        yTop,
        rightX,
        yTop,
      )
      ..lineTo(w, yTop)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.04 : 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, yTop, w, h - yTop));
    canvas.drawPath(fill, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassFoldSeparatorPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
