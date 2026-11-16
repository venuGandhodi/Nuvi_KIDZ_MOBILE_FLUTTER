import 'package:flutter/material.dart';
import 'nuvi_colors.dart';
import 'nuvi_radii.dart';

class NuviShadows {
  /// Warm, soft shadow for panels and large cards.
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x1A78461E), blurRadius: 22, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> productCard = [
    BoxShadow(color: Color(0x12172D2A), blurRadius: 22, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x24172D2A), blurRadius: 10, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> header = [
    BoxShadow(color: Color(0x14172D2A), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> bottomBar = [
    BoxShadow(color: Color(0x14172D2A), blurRadius: 16, offset: Offset(0, -4)),
  ];

  static const List<BoxShadow> ambientGlow = soft;
  static const List<BoxShadow> subtle = floating;
}

class NuviDecorations {
  static final BoxDecoration card = BoxDecoration(
    color: NuviColors.card,
    borderRadius: BorderRadius.circular(NuviRadii.card),
    boxShadow: NuviShadows.productCard,
  );

  static final BoxDecoration outlinedCard = BoxDecoration(
    color: NuviColors.card,
    borderRadius: BorderRadius.circular(NuviRadii.card),
    border: Border.all(color: NuviColors.line),
  );

  static final BoxDecoration inputField = BoxDecoration(
    color: NuviColors.card,
    borderRadius: BorderRadius.circular(NuviRadii.pill),
    border: Border.all(color: NuviColors.line, width: 1.5),
  );

  static final BoxDecoration pillSelected = BoxDecoration(
    color: NuviColors.ink,
    borderRadius: BorderRadius.circular(NuviRadii.pill),
  );

  static final BoxDecoration pillUnselected = BoxDecoration(
    color: NuviColors.sageSoft,
    borderRadius: BorderRadius.circular(NuviRadii.pill),
  );
}
