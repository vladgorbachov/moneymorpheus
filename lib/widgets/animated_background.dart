import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? darkBackgroundColor : lightBackgroundColor;

    return Stack(
      children: [
        Container(color: bgColor),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SpherePainter(
                progress: _controller.value,
                isDarkMode: widget.isDarkMode,
              ),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _SpherePainter extends CustomPainter {
  final double progress;
  final bool isDarkMode;

  _SpherePainter({required this.progress, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final sphere1X = size.width * 0.2 + (size.width * 0.3 * math.sin(t));
    final sphere1Y = size.height * 0.3 + (size.height * 0.2 * math.cos(t * 1.3));
    final sphere2X = size.width * 0.7 + (size.width * 0.2 * math.cos(t * 0.8));
    final sphere2Y = size.height * 0.6 + (size.height * 0.25 * math.sin(t * 1.1));

    final color1 = isDarkMode ? darkSphereColor1 : lightSphereColor1;
    final color2 = isDarkMode ? darkSphereColor2 : lightSphereColor2;
    final alpha1 = isDarkMode ? 0.4 : 0.25;
    final alpha2 = isDarkMode ? 0.5 : 0.2;

    final blur = 80.0;
    final rect1 = Rect.fromCircle(
      center: Offset(sphere1X, sphere1Y),
      radius: 120,
    );
    final rect2 = Rect.fromCircle(
      center: Offset(sphere2X, sphere2Y),
      radius: 150,
    );

    canvas.saveLayer(rect1.inflate(blur), Paint());
    final paint1 = Paint()
      ..color = color1.withValues(alpha: alpha1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(sphere1X, sphere1Y), 120, paint1);
    canvas.restore();

    canvas.saveLayer(rect2.inflate(blur), Paint());
    final paint2 = Paint()
      ..color = color2.withValues(alpha: alpha2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(sphere2X, sphere2Y), 150, paint2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpherePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
