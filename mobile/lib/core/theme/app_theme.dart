import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF0B2559);
  static const blue = Color(0xFF0757D3);
  static const darkBlue = Color(0xFF003EAC);
  static const text = Color(0xFF0B1834);
  static const muted = Color(0xFF64718B);
  static const hint = Color(0xFF667085);
  static const border = Color(0xFFD5DDEA);
  static const paleBlue = Color(0xFFEAF2FF);
  static const success = Color(0xFF087A36);
  static const warning = Color(0xFFA33E00);
  static const danger = Color(0xFFB42318);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7FAFF),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.text, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.muted, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: const TextStyle(color: AppColors.hint),
        prefixIconColor: AppColors.hint,
        suffixIconColor: AppColors.text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }
}
