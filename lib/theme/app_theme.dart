import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color inactive = Color(0xFF9CA3AF);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color teal = Color(0xFF4ECDC4);
  static const Color yellow = Color(0xFFEAB308);
  static const Color red = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color paymentGreen = Color(0xFF16A34A);
  static const Color amber = Color(0xFFF59E0B);
  static const Color purple = Color(0xFFA855F7);
  static const Color adminPrimary = Color(0xFF5B9BD5);
  static const Color savedHeart = Color(0xFFe95149);
  static const Color dark = Color(0xFF1A1A2E);
  static const Color bgLight = Color(0xFFF5F3EE);

  static const Map<String, Color> colorSwatches = {
    'Blue': Color(0xFF5B9BD5),
    'Red': Color(0xFFE8524A),
    'Green': Color(0xFF5BAD72),
    'Pink': Color(0xFFE8739A),
    'White': Color(0xFFFFFFFF),
    'Black': Color(0xFF000000),
    'Silver': Color(0xFFC0C0C0),
    'Brown': Color(0xFF8B4513),
    'Gold': Color(0xFFFFD700),
    'Purple': Color(0xFF800080),
  };
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.inactive,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
