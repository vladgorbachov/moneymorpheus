import 'package:flutter/material.dart';

class BitcoinBadge extends StatelessWidget {
  final double size;

  const BitcoinBadge({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BitcoinBadgePainter()),
    );
  }
}

class _BitcoinBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD36A), Color(0xFFF7931A), Color(0xFFD97706)],
      ).createShader(rect);
    canvas.drawCircle(center, radius, fill);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.045
      ..color = Colors.white.withValues(alpha: 0.34);
    canvas.drawCircle(center, radius * 0.92, ring);

    final textSpan = TextSpan(
      text: '₿',
      style: TextStyle(
        color: Colors.white,
        fontSize: size.shortestSide * 0.68,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final dx = (size.width - textPainter.width) / 2;
    final dy = (size.height - textPainter.height) / 2 - size.shortestSide * 0.03;
    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
