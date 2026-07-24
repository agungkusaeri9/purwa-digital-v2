import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const _primaryBlue = Color(0xFF2563EB); // Biru modern (vibrant blue)

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryBlue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50 (agak kebiruan)
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A), // Slate 900
          elevation: 0,
        ),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      );
}
