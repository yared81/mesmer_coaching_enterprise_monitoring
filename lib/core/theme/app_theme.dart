import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3D5AFE);
  static const Color darkBg = Color(0xFF0F172A); // Slate-900 / Navy Black
  static const Color darkCard = Color(0xFF1E293B); // Slate-800

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF4F6FB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF1F5F9)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.15),
      selectedColor: Colors.white,
      secondarySelectedColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      secondaryLabelStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
      brightness: Brightness.light,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      background: darkBg,
      surface: darkCard,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCard, // Or primaryColor if they want a blue appbar in dark mode too, but darkCard is standard
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCard,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: primaryColor,
      secondarySelectedColor: primaryColor,
      labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      brightness: Brightness.dark,
    ),
  );

  static final ThemeData highContrastLight = lightTheme.copyWith(
    scaffoldBackgroundColor: Colors.white, // Pure white instead of greyish
    primaryColor: const Color(0xFF0000FF), // Pure blue
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0000FF),
      primary: const Color(0xFF0000FF),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0000FF),
      foregroundColor: Colors.white,
      elevation: 4, // Higher shadow for contrast
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 1.5), // Strong black border
      ),
    ),
  );

  static final ThemeData highContrastDark = darkTheme.copyWith(
    scaffoldBackgroundColor: Colors.black, // Pure black
    primaryColor: Colors.cyanAccent, // Highly visible cyan against black
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.cyanAccent,
      primary: Colors.cyanAccent,
      background: Colors.black,
      surface: const Color(0xFF111111),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF111111),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1.5), // Strong white border
      ),
    ),
  );
}
