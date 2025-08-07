// =================================================================
// 📁 ARQUIVO: lib/core/theme/app_theme.dart
// =================================================================
// 🎨 Centraliza toda a configuração de temas, cores e estilos do app.

import 'package:flutter/material.dart';

class AppTheme {
  // Evita que a classe seja instanciada.
  AppTheme._();

  // =================================================================
  // 🎨 TEMA CLARO (LIGHT THEME)
  // =================================================================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Esquema de Cores
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.light,
    ),

    // Estilo da AppBar
    appBarTheme: const AppBarTheme(
      elevation: 2,
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    // Estilo dos Cards
    /*cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
    ),*/

    // Estilo dos Campos de Texto (Inputs)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),

    // Estilo dos Botões Elevados
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

    // Esquema de Cores
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.dark,
      // No tema escuro, a cor primária pode ser um pouco mais clara para ter melhor contraste
      primary: Colors.orange.shade400, 
    ),

    // Estilo da AppBar
    appBarTheme: AppBarTheme(
      elevation: 2,
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.orange.shade400,
      centerTitle: true,
    ),

    // Estilo dos Cards
    /*cardTheme: CardTheme(
      elevation: 1,
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade700,
          width: 1,
        ),
      ),
    ),*/

    // Estilo dos Campos de Texto (Inputs)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade900,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),

    // Estilo dos Botões Elevados
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
