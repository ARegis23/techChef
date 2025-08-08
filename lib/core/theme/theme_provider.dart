// =================================================================
// 📁 ARQUIVO: lib/core/providers/theme_provider.dart
// =================================================================
// 🧠 Gerencia o estado do tema atual do aplicativo.

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Método para atualizar o tema
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  // --- MÉTODOS ADICIONADOS PARA PERSISTÊNCIA ---

  // Converte uma string (vinda do Firestore) para ThemeMode
  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Converte ThemeMode para uma string (para salvar no Firestore)
  String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // Define o tema inicial a partir da preferência salva
  void loadThemeFromString(String themePreference) {
    _themeMode = _stringToThemeMode(themePreference);
    notifyListeners();
  }
}
