import 'package:flutter/material.dart';

class AppColors {
  static const orange = Color(0xFFFF9800);
  static const orangeDark = Color(0xFFF57C00);
  static const text = Color(0xFF1A1A1A);
  static const muted = Color(0xFF757575);
  static const border = Color(0xFFD9D9D9);
  static const background = Color(0xFFF7F7F7);
  static const danger = Color(0xFFD32F2F);
}

class AppTheme {
  static ThemeData get light {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        primary: AppColors.orange,
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
        border: outline,
        enabledBorder: outline,
        focusedBorder: outline.copyWith(
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
      ),
    );
  }
}
