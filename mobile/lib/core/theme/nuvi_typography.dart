import 'package:flutter/material.dart';
import 'nuvi_colors.dart';

/// Type scale: headings/buttons/prices in Baloo 2, body in Nunito, bag
/// headings in Fraunces. Festival heading fonts are applied per context via
/// `context.nuvi.type` (see nuvi_theme_ext.dart); this static theme is the
/// day-mode default and the fallback when no NUVI theme is in scope.
class NuviTypography {
  static const String headlineFont = 'Baloo2';
  static const String bodyFont = 'Nunito';
  static const String bagFont = 'Fraunces';

  static const double h1 = 28;
  static const double h2 = 22;
  static const double h3 = 18;
  static const double body = 15;
  static const double small = 13;
  static const double micro = 11;

  static const double headingHeight = 1.1;

  static TextTheme get textTheme => buildTextTheme(headlineFont);

  static TextTheme buildTextTheme(String headingFont) {
    final fallback = headingFont == headlineFont
        ? null
        : const [headlineFont];
    TextStyle heading(double size, FontWeight weight) => TextStyle(
      fontFamily: headingFont,
      fontFamilyFallback: fallback,
      fontSize: size,
      fontWeight: weight,
      height: headingHeight,
      color: NuviColors.ink,
    );
    TextStyle baloo(double size, FontWeight weight) => TextStyle(
      fontFamily: headlineFont,
      fontSize: size,
      fontWeight: weight,
      height: 1.2,
      color: NuviColors.ink,
    );
    TextStyle nunito(double size, FontWeight weight, {double height = 1.45}) =>
        TextStyle(
          fontFamily: bodyFont,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: NuviColors.ink,
        );

    return TextTheme(
      displayLarge: heading(30, FontWeight.w800),
      displayMedium: heading(h1, FontWeight.w700),
      displaySmall: heading(24, FontWeight.w700),
      headlineLarge: heading(24, FontWeight.w700),
      headlineMedium: heading(h2, FontWeight.w700),
      headlineSmall: heading(h3, FontWeight.w700),
      titleLarge: heading(h3, FontWeight.w700),
      titleMedium: baloo(16, FontWeight.w600),
      titleSmall: baloo(14, FontWeight.w600),
      bodyLarge: nunito(17, FontWeight.w400, height: 1.6),
      bodyMedium: nunito(body, FontWeight.w400),
      bodySmall: nunito(small, FontWeight.w400),
      labelLarge: baloo(14, FontWeight.w600),
      labelMedium: nunito(12, FontWeight.w700),
      labelSmall: nunito(micro, FontWeight.w700),
    );
  }
}
