// =================================================================
// 📁 ARQUIVO: lib/core/theme/app_theme.dart
// =================================================================
// 🎨 Centraliza toda a configuração de temas, cores e estilos do app.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // =================================================================
  // 🎨 TEMA CLARO (LIGHT THEME)
  // =================================================================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.light,
    ),

    // AppBar com fundo laranja e texto branco
    appBarTheme: const AppBarTheme(
      elevation: 2,
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    // cardTheme: Usamos CardThemeData para definir o tema.
    cardTheme: CardThemeData(
      elevation: 2.0,
      color: Colors.grey.shade100.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // InputDecorationTheme para campos de texto
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade100.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),

    // ElevatedButtonThemeData para botões elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  // =================================================================
  // 🎨 TEMA ESCURO (DARK THEME)
  // =================================================================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.dark,
      primary: Colors.orange.shade400, 
    ),

    // AppBar com fundo escuro e texto laranja
    appBarTheme: AppBarTheme(
      elevation: 2,
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.orange.shade400,
      centerTitle: true,
    ),

    // cardTheme: Usamos CardThemeData para definir o tema.
    cardTheme: CardThemeData(
      elevation: 2.0,
      color: Colors.grey.shade800.withOpacity(0.6), // Um pouco translúcido para o fundo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // InputDecorationTheme para campos de texto
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade900,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),

    // ElevatedButtonThemeData para botões elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
