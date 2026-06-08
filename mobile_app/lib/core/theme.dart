import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final darkModeProvider = StateProvider<bool>((ref) => false);

class AppTheme {
  static const primary = Color(0xFF0D9488);
  static const secondary = Color(0xFF14B8A6);
  static const background = Color(0xFFF8FAFC);
  static const gradientStart = Color(0xFF81FBB8);
  static const gradientEnd = Color(0xFF28C76F);
  static const darkGradientStart = Color(0xFF0F172A);
  static const darkGradientEnd = Color(0xFF134E4A);

  static const appGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [gradientStart, gradientEnd], stops: [0.1, 1.0], transform: GradientRotation(135 * 3.1415926535 / 180));
  static const darkGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkGradientStart, darkGradientEnd]);

  static ThemeData get light => _theme(Brightness.light, const ColorScheme.light(primary: primary, secondary: secondary, surface: Colors.white));
  static ThemeData get dark => _theme(Brightness.dark, ColorScheme.fromSeed(seedColor: secondary, brightness: Brightness.dark));

  static ThemeData _theme(Brightness brightness, ColorScheme scheme) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: scheme,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, backgroundColor: Colors.transparent),
        cardTheme: CardThemeData(
          elevation: 0,
          color: scheme.surface.withOpacity(brightness == Brightness.dark ? .86 : .96),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surface.withOpacity(brightness == Brightness.dark ? .7 : 1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      );
}
