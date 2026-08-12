import 'package:flutter/material.dart';
import 'nuvi_colors.dart';
import 'nuvi_radii.dart';

class NuviShadows {
  // Soft ambient glow shadow tinted with forest green
  static final List<BoxShadow> ambientGlow = [
    BoxShadow(
      color: NuviColors.primary.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> subtle = [
    BoxShadow(
      color: NuviColors.primary.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

class NuviDecorations {
  static final BoxDecoration card = BoxDecoration(
    color: NuviColors.surface,
    borderRadius: BorderRadius.circular(NuviRadii.card),
    border: Border.all(color: NuviColors.border, width: 1),
    boxShadow: NuviShadows.ambientGlow,
  );

  static final BoxDecoration inputField = BoxDecoration(
    color: NuviColors.surface,
    borderRadius: BorderRadius.circular(NuviRadii.small),
    border: Border.all(color: NuviColors.border, width: 1),
  );

  static final BoxDecoration pillSelected = BoxDecoration(
    color: NuviColors.primary,
    borderRadius: BorderRadius.circular(NuviRadii.pill),
  );

  static final BoxDecoration pillUnselected = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(NuviRadii.pill),
    border: Border.all(color: NuviColors.border, width: 1),
  );
}
