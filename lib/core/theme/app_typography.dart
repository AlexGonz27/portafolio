import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.1,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.firaCode(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.accentPrimary,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.firaCode(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.accentPrimary,
      ),
    );
  }
}
