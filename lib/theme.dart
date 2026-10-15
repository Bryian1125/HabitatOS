import 'package:flutter/material.dart';

/// HabitatOS dark mission-control palette.
class AppColors {
  static const background = Color(0xFF0A0E14);
  static const card = Color(0xFF111822);
  static const textPrimary = Color(0xFFE8EEF4);
  static const textSecondary = Color(0xFF8FA1B3);
  static const accent = Color(0xFF3B9EFF);
  static const target = Color(0xFF3DDC84);
  static const warning = Color(0xFFFFB020);
  static const critical = Color(0xFFFF4D4F);
  static const border = Color(0xFF1E2A38);
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.card,
    ),
  );
}