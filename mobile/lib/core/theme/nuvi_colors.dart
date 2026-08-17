import 'package:flutter/material.dart';

class NuviColors {
  // Brand Base Colors
  static const Color brandCream = Color(0xFFFCF4E8);
  static const Color brandSage = Color(0xFF767F5E); // olive accent
  static const Color brandPeach = Color(0xFFD6917A); // terracotta light
  static const Color brandMustard = Color(0xFFDBA751); // gold

  // Stitch Additions
  static const Color stitchDeepForestGreen = Color(0xFF0C1F13);
  static const Color stitchForestGreen = Color(0xFF16321F);
  static const Color stitchWarmCream = Color(0xFFFCF4E8);
  static const Color stitchMustard = Color(0xFFDBA751);
  static const Color stitchTerracotta = Color(0xFFD1714F);

  // Semantic Colors
  static const Color primary = stitchDeepForestGreen;
  static const Color primaryContainer = stitchForestGreen;
  static const Color onPrimary = Color(0xFFFEF8ED); // cream text on dark

  static const Color secondary = brandMustard;
  static const Color secondaryContainer = stitchMustard;
  static const Color onSecondary = Color(0xFF0C1A0F); // dark text on gold

  static const Color surface = stitchWarmCream;
  static const Color surfaceVariant = Color(0xFFFFFBF4); // card/near-white
  static const Color onSurface = Color(0xFF101F13); // primary text

  static const Color accent = stitchTerracotta;

  static const Color error = Color(0xFFBA1A1A);
  static const Color success = brandSage;

  static const Color border = Color(0xFFDDD7CD);
  static const Color borderStrong = Color(0xFFE3DDD3);

  // Text roles
  static const Color textSecondary = Color(0xFF767165); // muted 55%
  static const Color textTertiary = Color(0xFF686357); // muted 50%

  // Coupon banner
  static const Color couponBackground = Color(0xFFF7E9D6);
  static const Color couponBorder = Color(0xFFC39553);
  static const Color couponText = Color(0xFF402712);

  // Field / search bar
  static const Color fieldBackground = Color(0xFFFFFBF6);
}
