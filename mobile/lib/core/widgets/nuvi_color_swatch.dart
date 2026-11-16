import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import 'nuvi_pressable.dart';

/// 32pt colour circle with a selected ring.
class NuviColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final String semanticLabel;
  final double size;

  const NuviColorSwatch({
    super.key,
    required this.color,
    required this.semanticLabel,
    this.isSelected = false,
    this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return NuviPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Semantics(
        selected: isSelected,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: NuviMotion.of(context, NuviMotion.fast),
              width: size + 8,
              height: size + 8,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? NuviColors.ink : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: NuviColors.line),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
