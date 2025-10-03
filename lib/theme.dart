import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Cool Coastal Vibes palette
// 2B2D42 (navy), 8D99AE (blue-gray), EDF2F4 (off-white), EF233C (red), D90429 (dark red)
class AppColors {
  static const Color navy = Color(0xFF2B2D42);
  static const Color blueGray = Color(0xFF8D99AE);
  static const Color offWhite = Color(0xFFEDF2F4);
  static const Color red = Color(0xFFEF233C);
  static const Color darkRed = Color(0xFFD90429);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

ThemeData appThemeLight({Color accent = AppColors.red}) {
  final ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: accent,
    onPrimary: AppColors.white,
    secondary: AppColors.navy,
    onSecondary: AppColors.white,
    error: AppColors.darkRed,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.navy,
    surfaceContainerHighest: AppColors.blueGray,
    onSurfaceVariant: AppColors.navy,
    primaryContainer: AppColors.darkRed,
    onPrimaryContainer: AppColors.white,
    secondaryContainer: AppColors.blueGray,
    onSecondaryContainer: AppColors.white,
    outline: AppColors.blueGray,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.navy),
      displayMedium: TextStyle(color: AppColors.navy),
      displaySmall: TextStyle(color: AppColors.navy),
      headlineMedium: TextStyle(color: AppColors.navy),
      headlineSmall: TextStyle(color: AppColors.navy),
      titleLarge: TextStyle(color: AppColors.navy),
      bodyLarge: TextStyle(color: AppColors.navy),
      bodyMedium: TextStyle(color: AppColors.navy),
      labelMedium: TextStyle(color: AppColors.navy),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),
    chipTheme: const ChipThemeData(
      side: BorderSide(color: AppColors.blueGray),
      selectedColor: AppColors.darkRed,
      labelStyle: TextStyle(color: AppColors.navy),
    ),
  );
}

ThemeData appThemeDark({Color accent = AppColors.red}) {
  final ColorScheme scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: accent,
    onPrimary: AppColors.white,
    secondary: AppColors.blueGray,
    onSecondary: AppColors.black,
    error: AppColors.darkRed,
    onError: AppColors.white,
    surface: const Color(0xFF23283A),
    onSurface: AppColors.offWhite,
    surfaceContainerHighest: const Color(0xFF2E3450),
    onSurfaceVariant: AppColors.offWhite,
    primaryContainer: const Color(0xFF7A0E18),
    onPrimaryContainer: AppColors.white,
    secondaryContainer: const Color(0xFF3C4154),
    onSecondaryContainer: AppColors.offWhite,
    outline: AppColors.blueGray,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B1E2B),
      foregroundColor: AppColors.offWhite,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.offWhite),
      displayMedium: TextStyle(color: AppColors.offWhite),
      displaySmall: TextStyle(color: AppColors.offWhite),
      headlineMedium: TextStyle(color: AppColors.offWhite),
      headlineSmall: TextStyle(color: AppColors.offWhite),
      titleLarge: TextStyle(color: AppColors.offWhite),
      bodyLarge: TextStyle(color: AppColors.offWhite),
      bodyMedium: TextStyle(color: AppColors.offWhite),
      labelMedium: TextStyle(color: AppColors.offWhite),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: scheme.outline),
      selectedColor: scheme.primaryContainer,
      labelStyle: TextStyle(color: scheme.onSurface),
    ),
  );
}
