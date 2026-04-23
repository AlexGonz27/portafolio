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
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: AppTypography.textTheme,
      useMaterial3: true,
      
      // Customize specific widgets
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary.withOpacity(0.1),
          foregroundColor: AppColors.accentPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: AppColors.accentPrimary.withOpacity(0.5)),
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
}
