import 'package:flutter/material.dart';

class AdminTheme {
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
				colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
				// let shell paint the gradient
				scaffoldBackgroundColor: Colors.transparent,
				cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
			);
}
