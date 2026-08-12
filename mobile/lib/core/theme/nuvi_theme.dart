import 'package:flutter/material.dart';
import 'nuvi_colors.dart';
import 'nuvi_typography.dart';

class NuviTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: NuviColors.primary,
        onPrimary: NuviColors.onPrimary,
        primaryContainer: NuviColors.primaryContainer,
        secondary: NuviColors.secondary,
        onSecondary: NuviColors.onSecondary,
        secondaryContainer: NuviColors.secondaryContainer,
        surface: NuviColors.surface,
        onSurface: NuviColors.onSurface,
        surfaceContainerHighest: NuviColors.surfaceVariant,
        error: NuviColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: NuviColors.surface,
      textTheme: NuviTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: NuviColors.surface,
        foregroundColor: NuviColors.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NuviColors.primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
