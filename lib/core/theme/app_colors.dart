import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Dark space theme
  static const background = Color(0xFF03010A); // Very dark almost black blue
  static const surface = Color.fromRGBO(255, 255, 255, 0.05); // Glassmorphism surface
  static const surfaceHighlight = Color.fromRGBO(255, 255, 255, 0.1); 
  
  // Text colors - Dark
  static const textPrimary = Color(0xFFE8F4FD); // Cold white
  static const textSecondary = Color(0xFFA0AAC0); // Dimmed blue-grey
  
  // Accents - Dark
  static const accentPrimary = Color(0xFF7EFFF5); // Electric cyan (Star glow)
  static const accentSecondary = Color(0xFFC77DFF); // Nebula purple
  
  // Star elements - Dark
  static const starCore = Color(0xFFFFFFFF);
  
  // Semantic
  static const success = Color(0xFF00C897);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF4757);

  // Gradients - Dark
  static const cyanGradient = LinearGradient(
    colors: [Color(0xFF7EFFF5), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const purpleGradient = LinearGradient(
    colors: [Color(0xFFC77DFF), Color(0xFF5A189A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ================= LIGHT THEME PALETTE =================
  static const backgroundLight = Color(0xFFF6F8FC); // Luminous cosmic silver/ice white
  static const surfaceLight = Color.fromRGBO(255, 255, 255, 0.75); // Frosted glass light
  static const surfaceHighlightLight = Color.fromRGBO(255, 255, 255, 0.95);
  
  // Text colors - Light
  static const textPrimaryLight = Color(0xFF0B132B); // Deep midnight ink
  static const textSecondaryLight = Color(0xFF475569); // Muted slate navy
  
  // Accents - Light
  static const accentPrimaryLight = Color(0xFF0284C7); // Vivid deep celestial cyan/azure
  static const accentSecondaryLight = Color(0xFF7C3AED); // Royal nebula violet
  
  // Star elements - Light (Inverted: ink black / charcoal stars)
  static const starCoreLight = Color(0xFF0F172A); // Midnight obsidian star
  
  // Gradients - Light
  static const cyanGradientLight = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const purpleGradientLight = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dynamic getters based on brightness
  static Color getBackground(bool isDark) => isDark ? background : backgroundLight;
  static Color getSurface(bool isDark) => isDark ? surface : surfaceLight;
  static Color getTextPrimary(bool isDark) => isDark ? textPrimary : textPrimaryLight;
  static Color getTextSecondary(bool isDark) => isDark ? textSecondary : textSecondaryLight;
  static Color getAccentPrimary(bool isDark) => isDark ? accentPrimary : accentPrimaryLight;
  static Color getAccentSecondary(bool isDark) => isDark ? accentSecondary : accentSecondaryLight;
  static Color getStarCore(bool isDark) => isDark ? starCore : starCoreLight;
  static LinearGradient getCyanGradient(bool isDark) => isDark ? cyanGradient : cyanGradientLight;
  static LinearGradient getPurpleGradient(bool isDark) => isDark ? purpleGradient : purpleGradientLight;
}

extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get appBackground => AppColors.getBackground(isDark);
  Color get textPrimary => AppColors.getTextPrimary(isDark);
  Color get textSecondary => AppColors.getTextSecondary(isDark);
  Color get accentPrimary => AppColors.getAccentPrimary(isDark);
  Color get accentSecondary => AppColors.getAccentSecondary(isDark);
  Color get starCore => AppColors.getStarCore(isDark);
  LinearGradient get cyanGradient => AppColors.getCyanGradient(isDark);
  LinearGradient get purpleGradient => AppColors.getPurpleGradient(isDark);
}
