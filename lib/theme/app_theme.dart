import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Pink ───────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF6B9D);
  static const Color primaryDark = Color(0xFFE8507A);
  static const Color primaryLight = Color(0xFFFFD6E8);
  static const Color primaryXLight = Color(0xFFFFF0F7);

  // ── Accent Palette ───────────────────────────────────────────────────
  static const Color peach = Color(0xFFFF9A5C);
  static const Color yellow = Color(0xFFFFCC44);
  static const Color teal = Color(0xFF4ECDC4);
  static const Color mint = Color(0xFFB8F0EC);
  static const Color lavender = Color(0xFFB8A4F8);
  static const Color skyBlue = Color(0xFF93C5FD);

  // ── Feedback ─────────────────────────────────────────────────────────
  static const Color coral = Color(0xFFFF7B72);
  static const Color red = Color(0xFFFF4D6A);
  static const Color success = Color(0xFF3CB371);
  static const Color amber = Color(0xFFF59E0B);
  static const Color paymentGreen = Color(0xFF16A34A);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color dark = Color(0xFF2D1B2E);
  static const Color darkSecondary = Color(0xFF4A3050);
  static const Color textMid = Color(0xFF896A90);
  static const Color inactive = Color(0xFFCAB8D4);

  // ── Surfaces ─────────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFFFF8F4);
  static const Color surface = Color(0xFFFFF0EC);

  // ── Compatibility ────────────────────────────────────────────────────
  static const Color savedHeart = Color(0xFFFF4D6A);
  static const Color adminPrimary = Color(0xFF7B6ECD);
  static const Color purple = Color(0xFF9B7FE8);

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

class AppGradients {
  // Warm blush hero – home header, login hero
  static const LinearGradient hero = LinearGradient(
    colors: [Color(0xFFFFE4F2), Color(0xFFFFF8F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary pink action
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF90B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Warm banner – peach to amber
  static const LinearGradient banner = LinearGradient(
    colors: [Color(0xFFFF8FA3), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sale – coral-to-orange (kept)
  static const LinearGradient sale = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Teal (kept)
  static const LinearGradient teal = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Warm peach accent
  static const LinearGradient peach = LinearGradient(
    colors: [Color(0xFFFF9A5C), Color(0xFFFFCC80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppResponsive {
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isSmall(BuildContext context) => width(context) < 360;
  static bool isLarge(BuildContext context) => width(context) >= 428;
  static bool isTablet(BuildContext context) => width(context) >= 600;
  static bool isDesktop(BuildContext context) => width(context) >= 900;

  static double hp(BuildContext context) {
    if (isDesktop(context)) return 24.0;
    if (isTablet(context)) return 20.0;
    return isSmall(context) ? 12.0 : 16.0;
  }

  static double sp(BuildContext context, double base) {
    final scale = (width(context) / 390).clamp(0.85, 1.4);
    return base * scale;
  }

  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static int categoryColumns(BuildContext context) {
    if (isDesktop(context)) return 8;
    if (isTablet(context)) return 6;
    return 4;
  }

  static double cardW(BuildContext context) {
    final p = hp(context);
    final cols = gridColumns(context);
    final spacing = 12.0 * (cols - 1);
    return (width(context) - p * 2 - spacing) / cols;
  }

  static double gridAspectRatio(BuildContext context, {double bottomSectionH = 115}) {
    final cw = cardW(context);
    return cw / (cw + bottomSectionH);
  }

  static double bottomInset(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + 90;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.peach,
        surface: AppColors.bgLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgLight,
        hintStyle: const TextStyle(color: AppColors.inactive, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEED8E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEED8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
