import 'package:flutter/material.dart';

class MyColors {
  static const primary = Color(0xFF4F46E5);   // Indigo
  static const secondary = Color(0xFF06B6D4); // Cyan

  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);

  static const black = Color(0xFF0F172A);
  static const white = Color(0xFFFFFFFF);

  // Dark theme
  static const darkBackground = Color(0xFF020617);
  static const darkSurface = Color(0xFF0F172A);
}

class MyTheme {
  // 🌞 Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: MyColors.primary,
      onPrimary: Colors.white,
      secondary: MyColors.secondary,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: MyColors.surface,
      onSurface: Colors.black87,
    ),
    scaffoldBackgroundColor: MyColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
    cardTheme: CardThemeData(
      color: MyColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: MyColors.surface,
      indicatorColor: MyColors.primary,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // 🌙 Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: MyColors.primary,
      onPrimary: Colors.white,
      secondary: MyColors.secondary,
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.black,
      surface: MyColors.darkSurface,
      onSurface: Colors.white70,
    ),
    scaffoldBackgroundColor: MyColors.darkBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: MyColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: MyColors.darkSurface,
      indicatorColor: MyColors.primary,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}