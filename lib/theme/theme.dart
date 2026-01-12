import 'package:flutter/material.dart';

/// App Color Palette - Redesigned for Premium Fintech Aesthetic
class AppColors {
  // Primary Theme: Deep Navy & Emerald
  static const Color primary = Color(0xFF0F172A); // Deep Navy
  static const Color primaryLight = Color(0xFF1E293B); // Slate Navy
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  
  // Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Light Gray/Blue
  static const Color cardSurface = Colors.white;
  static const Color navySurface = Color(0xFF020617); // Darker Navy
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Dark Slate
  static const Color textSecondary = Color(0xFF64748B); // Muted Slate
  static const Color textMuted = Color(0xFF94A3B8); // Lighter Slate
  
  // Accents & States
  static const Color income = Color(0xFF10B981); // Emerald
  static const Color expense = Color(0xFFF43F5E); // Rose/Red
  static const Color info = Color(0xFF38BDF8); // Sky Blue
  static const Color warning = Color(0xFFF59E0B); // Amber
}

/// App Theme Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', 
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        error: AppColors.expense,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      // Card Theme - Redesigned for subtle depth
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      
      // Input Decoration - Sleeker forms
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      
      // Typography Redesign
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        displaySmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius constants
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}


