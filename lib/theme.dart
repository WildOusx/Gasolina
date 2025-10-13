import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// New refined palette based on the original palette but tuned for better contrast
class AppColors {
  static const Color primary = Color(0xFFB0002E); // warmer accent red
  static const Color navy = Color(0xFF1F2430);
  static const Color slate = Color(0xFF728096);
  static const Color bg = Color(0xFFF7F9FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
}

ThemeData appThemeLight({Color accent = AppColors.primary}) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
    primary: accent,
    secondary: AppColors.navy,
    error: AppColors.error,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primaryContainer.withAlpha((0.98 * 255).round()),
      foregroundColor: scheme.onPrimaryContainer,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: scheme.onSurface),
      labelMedium: TextStyle(color: scheme.onSurfaceVariant),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: scheme.outline),
      selectedColor: scheme.primaryContainer,
      labelStyle: TextStyle(color: scheme.onSurface),
    ),
  );
}

ThemeData appThemeDark({Color accent = AppColors.primary}) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
    primary: accent,
    secondary: AppColors.slate,
    error: AppColors.error,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF0F1720),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0B1220),
      foregroundColor: scheme.onSurface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: scheme.onSurface),
      labelMedium: TextStyle(color: scheme.onSurfaceVariant),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: scheme.outline),
      selectedColor: scheme.primaryContainer,
      labelStyle: TextStyle(color: scheme.onSurface),
    ),
  );
}

// Wrappers para mantener compatibilidad con código previo
ThemeData buildLightTheme(Color accent) => appThemeLight(accent: accent);
ThemeData buildDarkTheme(Color accent) => appThemeDark(accent: accent);
