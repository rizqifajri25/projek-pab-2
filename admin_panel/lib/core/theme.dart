import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminDarkModeProvider = StateProvider<bool>((ref) => false);

class AdminTheme {
  static const gradientStart = Color(0xFF81FBB8);
  static const gradientEnd = Color(0xFF28C76F);
  static const darkGradientStart = Color(0xFF020617);
  static const darkGradientEnd = Color(0xFF134E4A);
  static const appGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [gradientStart, gradientEnd], stops: [0.1, 1.0], transform: GradientRotation(135 * 3.1415926535 / 180));
  static const darkGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkGradientStart, darkGradientEnd]);

  static ThemeData get light => _theme(Brightness.light, ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)));
  static ThemeData get dark => _theme(Brightness.dark, ColorScheme.fromSeed(seedColor: const Color(0xFF14B8A6), brightness: Brightness.dark));

  static ThemeData _theme(Brightness brightness, ColorScheme scheme) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: scheme,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        cardTheme: CardThemeData(
          color: scheme.surface.withOpacity(brightness == Brightness.dark ? .88 : .96),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 0,
        ),
      );
}
