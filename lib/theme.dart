import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF0B090A);
  static const Color secondaryDark = Color(0xFF161A1D);
  static const Color deepRed = Color(0xFF660708);
  static const Color primaryRed = Color(0xFFA4161A);
  static const Color brightRed = Color(0xFFBA181B);
  static const Color vibrantRed = Color(0xFFE5383B);
  static const Color lightGrey = Color(0xFFB1A7A6);
  static const Color offWhite = Color(0xFFF5F3F4);
  static const Color pureWhite = Color(0xFFFFFFFF);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryRed,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primaryRed,
    secondary: AppColors.vibrantRed,
    surface: AppColors.secondaryDark,
    background: AppColors.primaryDark,
    error: AppColors.deepRed,
  ),
  scaffoldBackgroundColor: AppColors.primaryDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.secondaryDark,
    foregroundColor: AppColors.pureWhite,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.pureWhite),
    displayMedium: TextStyle(color: AppColors.pureWhite),
    displaySmall: TextStyle(color: AppColors.pureWhite),
    headlineMedium: TextStyle(color: AppColors.pureWhite),
    headlineSmall: TextStyle(color: AppColors.pureWhite),
    titleLarge: TextStyle(color: AppColors.pureWhite),
    bodyLarge: TextStyle(color: AppColors.offWhite),
    bodyMedium: TextStyle(color: AppColors.lightGrey),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.vibrantRed,
      foregroundColor: AppColors.pureWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryRed,
      foregroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.vibrantRed),
  ),
);
