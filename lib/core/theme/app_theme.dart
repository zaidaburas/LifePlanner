import 'package:flutter/material.dart';

class AppColors {
  // Primary - Teal
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  // Secondary - Orange
  static const Color secondary = Color(0xFFFF6F00);
  static const Color secondaryLight = Color(0xFFFFB300);
  static const Color secondaryDark = Color(0xFFE65100);

  // Accent colors for categories
  static const Color accentBlue = Color(0xFF1565C0);
  static const Color accentPurple = Color(0xFF6A1B9A);
  static const Color accentGreen = Color(0xFF2E7D32);
  static const Color accentRed = Color(0xFFC62828);
  static const Color accentPink = Color(0xFFAD1457);
  static const Color accentIndigo = Color(0xFF283593);

  // Status colors
  static const Color statusNotStarted = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF1E88E5);
  static const Color statusPaused = Color(0xFFFB8C00);
  static const Color statusCompleted = Color(0xFF43A047);

  // Priority colors
  static const Color priorityLow = Color(0xFF66BB6A);
  static const Color priorityMedium = Color(0xFFFFB300);
  static const Color priorityHigh = Color(0xFFEF5350);
  static const Color priorityCritical = Color(0xFFB71C1C);

  // Neutral
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color border = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkSurfaceVariant = Color(0xFF252836);
  static const Color darkBorder = Color(0xFF2D3142);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dashboardGradient = LinearGradient(
    colors: [Color(0xFF00695C), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Task type colors
  static const Map<String, Color> taskTypeColors = {
    'تعلم': Color(0xFF1565C0),
    'برمجة': Color(0xFF6A1B9A),
    'جامعة': Color(0xFF00695C),
    'عمل': Color(0xFFE65100),
    'شخصي': Color(0xFFAD1457),
    'شبكة': Color(0xFF283593),
    'تصميم': Color(0xFF558B2F),
    'تطوير ذات': Color(0xFF4527A0),
    'أخرى': Color(0xFF455A64),
  };
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Cairo',
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Cairo',
        ),
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontFamily: 'Cairo',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Cairo'),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary, fontFamily: 'Cairo'),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontFamily: 'Cairo'),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryLight.withOpacity(0.2),
        labelStyle: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
          fontFamily: 'Cairo',
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary, fontFamily: 'Cairo'),
        hintStyle: const TextStyle(color: AppColors.darkBorder, fontFamily: 'Cairo'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Cairo'),
      ),
    );
  }
}
