import 'package:flutter/material.dart';
import 'package:csp10_app/core/theme/colors.dart';

class MyTheme {
  // Light Theme
  static final lightTheme = ThemeData(
    colorSchemeSeed: MaterialColor(
      MyColors.primary.toARGB32(),
      <int, Color>{
        50: MyColors.primary.withValues(alpha: 0.1),
        100: MyColors.primary.withValues(alpha: 0.2),
        200: MyColors.primary.withValues(alpha: 0.3),
        300: MyColors.primary.withValues(alpha: 0.4),
        400: MyColors.primary.withValues(alpha: 0.5),
        500: MyColors.primary.withValues(alpha: 0.6),
        600: MyColors.primary.withValues(alpha: 0.7),
        700: MyColors.primary.withValues(alpha: 0.8),
        800: MyColors.primary.withValues(alpha: 0.9),
        900: MyColors.primary.withValues(alpha: 1.0),
      },
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.white,
  );

  // Dark Theme
  // TODO: Add dark theme colors
  static final darkTheme = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorSchemeSeed: MaterialColor(
      MyColors.secondary.toARGB32(),
      <int, Color>{
        50: MyColors.secondary.withValues(alpha: 0.1),
        100: MyColors.secondary.withValues(alpha: 0.2),
        200: MyColors.secondary.withValues(alpha: 0.3),
        300: MyColors.secondary.withValues(alpha: 0.4),
        400: MyColors.secondary.withValues(alpha: 0.5),
        500: MyColors.secondary.withValues(alpha: 0.6),
        600: MyColors.secondary.withValues(alpha: 0.7),
        700: MyColors.secondary.withValues(alpha: 0.8),
        800: MyColors.secondary.withValues(alpha: 0.9),
        900: MyColors.secondary.withValues(alpha: 1.0),
      },
    ),
    scaffoldBackgroundColor: MyColors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: MyColors.black,
      elevation: 0,
      iconTheme: IconThemeData(
        color: MyColors.primary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MyColors.black,
      selectedItemColor: MyColors.primary,
      unselectedItemColor: MyColors.secondary,
    ),
  );
}
