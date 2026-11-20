import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import 'nuvi_decor.dart';

/// Soft cream backdrop for the splash, onboarding and sign-in screens: a
/// sage blob top-left, a peach blob top-right and rolling hills at the
/// bottom. [child] is drawn on top.
class NuviWelcomeBackdrop extends StatelessWidget {
  final Widget child;
  final bool hills;

  const NuviWelcomeBackdrop({
    super.key,
    required this.child,
    this.hills = true,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NuviColors.cream,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -60,
            width: 170,
            height: 150,
            child: ClipPath(
              clipper: const NuviBlobClipper(seed: 2),
              child: ColoredBox(color: NuviColors.sage.withValues(alpha: 0.28)),
            ),
          ),
          Positioned(
            top: 40,
            right: -70,
            width: 160,
            height: 150,
            child: ClipPath(
              clipper: const NuviBlobClipper(seed: 5),
              child: ColoredBox(
                color: NuviColors.peach.withValues(alpha: 0.22),
              ),
            ),
          ),
          if (hills)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NuviHills(
                height: 120,
                back: Color(0xFFE6EBD7),
                front: Color(0xFFD5E0BF),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
