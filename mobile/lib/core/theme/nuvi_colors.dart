import 'package:flutter/material.dart';

class NuviColors {
  // Brand Base Colors
  static const Color brandCream = Color(0xFFFFF9F3);
  static const Color brandSage = Color(0xFF9AA38C);
  static const Color brandPeach = Color(0xFFF2B49A);
  static const Color brandMustard = Color(0xFFEAB83D);

  // Stitch Additions
  static const Color stitchDeepForestGreen = Color(0xFF082719);
  static const Color stitchForestGreen = Color(0xFF1F3D2E);
  static const Color stitchWarmCream = Color(0xFFFFF8F0);
  static const Color stitchMustard = Color(0xFFFDB244);
  static const Color stitchTerracotta = Color(0xFFEB8467);

  // Semantic Colors
  static const Color primary = stitchDeepForestGreen;
  static const Color primaryContainer = stitchForestGreen;
  static const Color onPrimary = Colors.white;

  static const Color secondary = brandMustard;
  static const Color secondaryContainer = stitchMustard;
  static const Color onSecondary = stitchDeepForestGreen;

  static const Color surface = stitchWarmCream;
  static const Color surfaceVariant = brandCream;
  static const Color onSurface = Color(0xFF1E1B14); // Deep Charcoal

  static const Color accent = stitchTerracotta;

  static const Color error = Color(0xFFBA1A1A);
  static const Color success = brandSage;

  static const Color border = Color(0xFFE9E1D6); // Subtly darker cream
}
