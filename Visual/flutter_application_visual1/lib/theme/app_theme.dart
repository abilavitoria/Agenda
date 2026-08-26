import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Tema Claro (Roxo, Branco Off e Letras em Preto)
  static const Color lightPrimary = Color(0xFF7E22CE); // Roxo elegante
  static const Color lightPrimaryVariant = Color(0xFF6B21A8);
  static const Color lightSecondary = Color(0xFF9333EA);
  static const Color lightBackground = Color(0xFFFAF8F5); // Branco Off
  static const Color lightSurface = Color(0xFFF4EFEA); // Branco Off para cards/containers
  static const Color lightSurfaceLight = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0A0A0A); // Letras em preto
  static const Color lightTextSecondary = Color(0xFF333333); // Preto suave
  static const Color lightBorder = Color(0xFFDFD7CC);

  // Paleta Tema Escuro (Preto, Roxo e Escrita Branca)
  static const Color darkPrimary = Color(0xFFA855F7); // Roxo vibrante para modo escuro
  static const Color darkPrimaryVariant = Color(0xFFC084FC);
  static const Color darkSecondary = Color(0xFF9333EA);
  static const Color darkBackground = Color(0xFF09090B); // Preto absoluto
  static const Color darkSurface = Color(0xFF14121E); // Preto com leve nuance roxa
  static const Color darkSurfaceLight = Color(0xFF1F1B2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Escrita em branco
  static const Color darkTextSecondary = Color(0xFFD4D4D8); // Branco suave
  static const Color darkBorder = Color(0xFF2E2742);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFEDE9FE),
        onPrimaryContainer: lightTextPrimary,
        secondary: lightSecondary,
        onSecondary: Colors.white,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        error: Color(0xFFDC2626),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: lightPrimary),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: lightBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: const BorderSide(color: lightPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceLight,
        hintStyle: const TextStyle(color: Color(0xFF737373), fontSize: 14),
        labelStyle: const TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w500),
        prefixIconColor: lightPrimary,
        suffixIconColor: lightPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: lightTextSecondary, fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: Colors.black,
        primaryContainer: darkSurfaceLight,
        onPrimaryContainer: darkTextPrimary,
        secondary: darkSecondary,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: darkPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceLight,
        hintStyle: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
        labelStyle: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
        prefixIconColor: darkPrimary,
        suffixIconColor: darkPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12),
      ),
    );
  }
}
