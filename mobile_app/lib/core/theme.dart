import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF0D9488);
  static const secondary = Color(0xFF14B8A6);
  static const background = Color(0xFFF8FAFC);
  static const gradientStart = Color(0xFF81FBB8);
  static const gradientEnd = Color(0xFF28C76F);
  static const appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
    stops: [0.1, 1.0],
    transform: GradientRotation(135 * 3.1415926535 / 180),
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        // Make scaffold background transparent so shell can paint gradient
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      );
}
