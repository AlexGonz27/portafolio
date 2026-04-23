import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Dark space theme
  static const background = Color(0xFF03010A); // Very dark almost black blue
  static const surface = Color.fromRGBO(255, 255, 255, 0.05); // Glassmorphism surface
  static const surfaceHighlight = Color.fromRGBO(255, 255, 255, 0.1); 
  
  // Text colors
  static const textPrimary = Color(0xFFE8F4FD); // Cold white
  static const textSecondary = Color(0xFFA0AAC0); // Dimmed blue-grey
  
  // Accents
  static const accentPrimary = Color(0xFF7EFFF5); // Electric cyan (Star glow)
  static const accentSecondary = Color(0xFFC77DFF); // Nebula purple
  
  // Star elements
  static const starCore = Color(0xFFFFFFFF);
  
  // Semantic
  static const success = Color(0xFF00C897);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF4757);

  // Gradients
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
}
