import 'package:flutter/material.dart';

import '../core/constants.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isDarkMode
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkGradientStart, darkGradientEnd],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightGradientStart, lightGradientEnd],
          );

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
