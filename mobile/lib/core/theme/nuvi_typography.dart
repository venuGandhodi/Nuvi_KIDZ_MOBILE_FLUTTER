import 'package:flutter/material.dart';
import 'nuvi_colors.dart';

class NuviTypography {
  static const String headlineFont = 'Quicksand';
  static const String bodyFont = 'BeVietnamPro';

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: headlineFont,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02,
        color: NuviColors.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: headlineFont,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: NuviColors.onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: headlineFont,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: NuviColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: headlineFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: NuviColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: NuviColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: NuviColors.onSurface,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.05,
        color: NuviColors.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: NuviColors.onSurface,
      ),
    );
  }
}
