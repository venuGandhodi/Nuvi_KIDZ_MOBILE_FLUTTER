import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_decorations.dart';
import '../theme/nuvi_typography.dart';

class NuviPillSelector extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final bool dense;
  final VoidCallback? onTap;

  const NuviPillSelector({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isDisabled = false,
    this.dense = false,
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
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 14 : 20,
          vertical: dense ? 6 : 10,
        ),
        decoration: decoration,
        child: Text(
          label,
          style: NuviTypography.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontSize: dense ? 12 : null,
          ),
        ),
      ),
    );
  }
}
