import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.coral,
      primary: AppColors.coral,
      secondary: AppColors.green,
      surface: AppColors.white,
      onSurface: AppColors.navy,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.navy,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.navy,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.navy, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.muted, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
