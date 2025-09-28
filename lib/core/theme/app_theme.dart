import 'package:flutter/material.dart';
import 'package:handscore/core/theme/app_colors.dart';
import 'package:handscore/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      secondary: AppColors.darkSecondary,
      onSecondary: Colors.white,
      tertiary: AppColors.darkTertiary,
      onTertiary: Colors.black,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceTint: AppColors.darkPrimary,
      outline: Color(0xFF374151),
      shadow: Colors.black,
      scrim: Colors.black54,
      inversePrimary: AppColors.lightPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      textTheme: AppTypography.textTheme(scheme.onSurface),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.secondary,
        unselectedItemColor: scheme.onSurface.withOpacity(.6),
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0B1220),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondary.withOpacity(.12),
        labelStyle: TextStyle(color: scheme.onSurface),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      secondary: AppColors.lightSecondary,
      onSecondary: Colors.white,
      tertiary: AppColors.lightAccent,
      onTertiary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceTint: AppColors.lightPrimary,
      outline: Color(0xFFE5E7EB),
      shadow: Colors.black12,
      scrim: Colors.black38,
      inversePrimary: AppColors.darkPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      textTheme: AppTypography.textTheme(scheme.onSurface),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.secondary,
        unselectedItemColor: scheme.onSurface.withOpacity(.7),
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightMuted,
        labelStyle: TextStyle(color: scheme.onSurface),
        side: BorderSide.none,
      ),
    );
  }
}
