// =================================================================
// 📁 ARQUIVO: lib/modules/settings/views/settings_page.dart
// =================================================================
// ⚙️ Tela de Configurações, agora com persistência de tema.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../services/database_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Claro';
      case ThemeMode.dark: return 'Escuro';
      case ThemeMode.system: return 'Padrão do Sistema';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema do Aplicativo'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? newMode) async {
                if (newMode != null && currentUser != null) {
                  // 1. Atualiza o estado local do app
                  themeProvider.setThemeMode(newMode);
                  // 2. Salva a nova preferência no Firestore
                  final themeString = themeProvider.themeModeToString(newMode);
                  await DatabaseService(uid: currentUser.uid).updateUserThemePreference(themeString);
                }
              },
              items: ThemeMode.values.map((ThemeMode mode) {
                return DropdownMenuItem<ThemeMode>(
                  value: mode,
                  child: Text(_getThemeModeText(mode)),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          // ... resto das opções
        ],
      ),
    );
  }
}
