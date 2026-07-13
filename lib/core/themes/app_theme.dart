import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _primaryRed = Color(0xFFC62828);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryRed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F7),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2B1616),
          elevation: 0,
        ),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      );
}
