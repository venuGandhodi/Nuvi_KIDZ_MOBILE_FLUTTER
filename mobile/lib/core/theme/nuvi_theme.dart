import 'package:flutter/material.dart';
import 'nuvi_colors.dart';
import 'nuvi_festival.dart';
import 'nuvi_radii.dart';
import 'nuvi_theme_ext.dart';
import 'nuvi_typography.dart';

class NuviTheme {
  static ThemeData get lightTheme => build(null);

  static ThemeData build(NuviFestival? festival) {
    final x = NuviThemeX.forFestival(festival);
    final textTheme = NuviTypography.buildTextTheme(x.headingFont);

    return ThemeData(
      useMaterial3: true,
      fontFamily: NuviTypography.bodyFont,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: NuviColors.ink,
        onPrimary: NuviColors.cream,
        primaryContainer: NuviColors.nightGreen,
        onPrimaryContainer: NuviColors.moonCream,
        secondary: x.gold,
        onSecondary: x.onGold,
        secondaryContainer: x.goldSoft,
        onSecondaryContainer: NuviColors.nightGreen,
        tertiary: x.sage,
        onTertiary: NuviColors.nightGreen,
        surface: NuviColors.cream,
        onSurface: NuviColors.ink,
        onSurfaceVariant: NuviColors.inkMuted,
        surfaceContainerHighest: NuviColors.card,
        outline: NuviColors.line,
        outlineVariant: NuviColors.line,
        error: NuviColors.sale,
        onError: NuviColors.white,
      ),
      scaffoldBackgroundColor: NuviColors.cream,
      canvasColor: NuviColors.cream,
      textTheme: textTheme,
      extensions: [x],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: NuviColors.cream,
        foregroundColor: NuviColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: x.h3,
      ),
      iconTheme: const IconThemeData(color: NuviColors.ink),
      dividerTheme: const DividerThemeData(
        color: NuviColors.line,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: x.gold),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NuviColors.ink,
        contentTextStyle: x.nunito(14, weight: FontWeight.w600, color: NuviColors.cream),
        actionTextColor: x.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NuviRadii.pill),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: NuviColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NuviRadii.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NuviColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
        ),
        titleTextStyle: x.h3,
        contentTextStyle: x.body,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NuviColors.card,
        hintStyle: x.nunito(15, color: NuviColors.inkFaint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NuviRadii.pill),
          borderSide: const BorderSide(color: NuviColors.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NuviRadii.pill),
          borderSide: const BorderSide(color: NuviColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NuviRadii.pill),
          borderSide: const BorderSide(color: NuviColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NuviRadii.pill),
          borderSide: const BorderSide(color: NuviColors.sale, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NuviColors.ink,
          textStyle: x.button,
          minimumSize: const Size(44, 44),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: x.sageSoft,
        selectedColor: NuviColors.ink,
        labelStyle: x.nunito(13, weight: FontWeight.w700),
        secondaryLabelStyle: x.nunito(13, weight: FontWeight.w700, color: NuviColors.cream),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? NuviColors.white
              : NuviColors.inkFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? x.gold
              : NuviColors.sageSoft,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NuviColors.ink;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(NuviColors.ink),
      ),
    );
  }
}
