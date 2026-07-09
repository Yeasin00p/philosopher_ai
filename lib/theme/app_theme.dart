import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system for the Philosopher AI app.
class AppColors {
  AppColors._();

  static const Color obsidian = Color(0xFF07070F);
  static const Color navy = Color(0xFF0C0C1E);
  static const Color card = Color(0xFF111128);
  static const Color cardAlt = Color(0xFF13132A);
  static const Color gold = Color(0xFFC9A84C);
  static const Color lightGold = Color(0xFFE8C96A);
  static const Color cream = Color(0xFFF5EDD8);
  static const Color parchment = Color(0xFF9E9480);
  static const Color dimWhite = Color(0xFFB0A898);
  static const Color userBubble = Color(0xFF1A1108);
  static const Color userBubbleBorder = Color(0xFF3A2A10);
  static const Color philosopherBubble = Color(0xFF0E0E22);
  static const Color philosopherBubbleBorder = Color(0xFF2A2A50);
  static const Color inputBg = Color(0xFF0F0F22);
  static const Color divider = Color(0xFF1C1C36);
  static const Color error = Color(0xFF8B3A3A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.obsidian,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.lightGold,
      surface: AppColors.navy,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navy,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: AppColors.cream,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      iconTheme: const IconThemeData(color: AppColors.gold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.parchment,
        fontSize: 14,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        color: AppColors.cream,
        fontSize: 38,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        color: AppColors.cream,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: AppColors.cream,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: AppColors.cream,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: AppColors.dimWhite,
        fontSize: 16,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.dimWhite,
        fontSize: 14,
        height: 1.5,
      ),
      labelSmall: GoogleFonts.inter(
        color: AppColors.parchment,
        fontSize: 11,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
