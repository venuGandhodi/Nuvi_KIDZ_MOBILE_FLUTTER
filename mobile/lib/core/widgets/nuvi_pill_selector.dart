import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_decorations.dart';
import '../theme/nuvi_typography.dart';

class NuviPillSelector extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const NuviPillSelector({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = isSelected
        ? NuviDecorations.pillSelected
        : NuviDecorations.pillUnselected;

    Color textColor = isSelected ? NuviColors.onPrimary : NuviColors.onSurface;

    if (isDisabled) {
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: NuviDecorations.pillUnselected.borderRadius,
        border: Border.all(color: NuviColors.border.withValues(alpha: 0.5)),
      );
      textColor = textColor.withValues(alpha: 0.5);
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: decoration,
        child: Text(
          label,
          style: NuviTypography.textTheme.labelLarge?.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}
