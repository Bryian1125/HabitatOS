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
  static const warning = Color(0xFFD9A441);
  static const critical = Color(0xFFD96A6A);
  static const border = Color(0xFF222222);
}

final _dialogShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
  side: const BorderSide(color: AppColors.border, width: 0.5),
);

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
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.card,
      error: AppColors.critical,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: _dialogShape,
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      floatingLabelStyle: const TextStyle(color: AppColors.accent),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      errorStyle: const TextStyle(color: AppColors.critical),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.accent),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: AppColors.background,
      headerForegroundColor: AppColors.textPrimary,
      shape: _dialogShape,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.card,
      dialBackgroundColor: AppColors.background,
      dialHandColor: AppColors.accent,
      dialTextColor: AppColors.textPrimary,
      entryModeIconColor: AppColors.textSecondary,
      shape: _dialogShape,
    ),
  );
}
