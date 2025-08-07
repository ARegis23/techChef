// =================================================================
// 📁 ARQUIVO: lib/core/theme/theme_provider.dart
// =================================================================
// 🧠 Gerencia o estado do tema atual do aplicativo.

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // O modo de tema inicial é o do sistema.
  ThemeMode _themeMode = ThemeMode.system;

  // Getter para que a UI possa ler o tema atual.
  ThemeMode get themeMode => _themeMode;

  // Método para atualizar o tema e notificar todos os widgets que o escutam.
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Avisa a UI para se redesenhar com o novo tema.
  }
}
