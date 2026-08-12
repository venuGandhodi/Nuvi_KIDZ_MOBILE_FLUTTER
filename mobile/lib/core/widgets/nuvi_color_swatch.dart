import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';

class NuviColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final String semanticLabel;

  const NuviColorSwatch({
    super.key,
    required this.color,
    required this.semanticLabel,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: semanticLabel,
        selected: isSelected,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? NuviColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: NuviColors.border, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
