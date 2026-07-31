import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
      bodyMedium: TextStyle(color: AppColors.ink),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF2A2A3E),
    ),
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    // ✅ 修正：使用 CardThemeData 而非 CardTheme
    cardTheme: const CardThemeData(
      color: Color(0xFF2A2A3E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
