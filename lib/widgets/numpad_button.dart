import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';

class NumpadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const NumpadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isWide = false,
  });

  @override
  State<NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<NumpadButton>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Color _neonColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? accentColor : lightAccentColor;
  }

  Color _textColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.85);
  }

  Color _fillColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.6);
  }

  Color _borderBaseColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
  }

  @override
  Widget build(BuildContext context) {
    final neon = _neonColor(context);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        widget.onTap();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _shimmerController]),
        builder: (context, _) {
          final pulse = 0.6 + (_pulseController.value * 0.4);
          final shimmer = 0.5 + (math.sin(_shimmerController.value * 2 * math.pi) * 0.3);
          final glowAlpha = (pulse * shimmer).clamp(0.3, 1.0);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()
              ..scaleByDouble(
                _isPressed ? 0.95 : 1.0,
                _isPressed ? 0.95 : 1.0,
                1.0,
                1.0,
              ),
            decoration: BoxDecoration(
              color: _fillColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: neon.withValues(alpha: glowAlpha),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: neon.withValues(alpha: glowAlpha * 0.6),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: neon.withValues(alpha: glowAlpha * 0.3),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
                ...(_isPressed
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.15),
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ]),
              ],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.isWide ? 14 : 22,
                  fontWeight: FontWeight.w500,
                  color: _textColor(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
