import 'package:flutter/material.dart';

import 'nuvi_animations.dart';

/// Brand loading state: the elephant mascot, floating in place, used instead
/// of a generic [CircularProgressIndicator] wherever a screen or section is
/// waiting on data.
class NuviLoadingIndicator extends StatelessWidget {
  final double size;

  const NuviLoadingIndicator({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return NuviMascotAnimated(
      loop: NuviMascotLoop.float,
      child: Image.asset(
        'assets/images/brand/nuvi_elephant_mascot.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
