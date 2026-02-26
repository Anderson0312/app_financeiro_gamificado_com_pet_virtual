import 'package:flutter/material.dart';

/// Tema lúdico e limpo do aplicativo.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B9BD1),
        brightness: Brightness.light,
        primary: const Color(0xFF6B9BD1),
        secondary: const Color(0xFFE8B86D),
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
