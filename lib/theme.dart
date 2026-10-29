import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HabitatOS dark mission-control palette.
class AppColors {
  static const background = Color(0xFF0F0F0F);
  static const card = Color(0xFF181818);
  static const textPrimary = Color(0xFFEAEAEA);
  static const textSecondary = Color(0xFF777777);
  static const accent = Color(0xFFCCCCCC);
  static const target = Color(0xFFAAAAAA);
  static const warning = Color(0xFFCCCCCC);
  static const critical = Color(0xFFCCCCCC);
  static const border = Color(0xFF222222);
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(base.textTheme),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.card,
    ),
  );
}