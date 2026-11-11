import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPrimary,
        secondary: AppColors.accentSecondary,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: AppTypography.getTextTheme(true),
      useMaterial3: true,
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.1),
          foregroundColor: AppColors.accentPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: AppColors.accentPrimary.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.accentPrimary,
        size: 24,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentPrimaryLight,
        secondary: AppColors.accentSecondaryLight,
        surface: AppColors.backgroundLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: AppTypography.getTextTheme(false),
      useMaterial3: true,
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimaryLight.withValues(alpha: 0.12),
          foregroundColor: AppColors.accentPrimaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: AppColors.accentPrimaryLight.withValues(alpha: 0.6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.accentPrimaryLight,
        size: 24,
      ),
    );
  }
}
