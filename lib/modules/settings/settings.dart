// =================================================================
// 📁 ARQUIVO: lib/modules/settings/settings.dart
// =================================================================
// ⚙️ Tela de Configurações.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Função auxiliar para converter ThemeMode em texto legível
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Padrão do Sistema';
    }
  }


  @override
  Widget build(BuildContext context) {

    // Acessa o provider para ler o estado atual e para poder alterá-lo.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Ativar notificações'),
            value: true,
            onChanged: (bool value) {
              // Lógica para alterar a configuração de notificação
            },
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            title: const Text('Editar Perfil'),
            leading: const Icon(Icons.person),
            onTap: () {
              // Navegar para a tela de edição de perfil
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema do Aplicativo'),
            trailing: DropdownButton<ThemeMode>(
              // O valor atual do dropdown é o tema do provider
              value: themeProvider.themeMode,
              // Ao selecionar um novo item...
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  // ...chama o método para atualizar o tema no provider.
                  themeProvider.setThemeMode(newMode);
                }
              },
              // Mapeia cada opção do enum ThemeMode para um item no dropdown
              items: ThemeMode.values.map((ThemeMode mode) {
                return DropdownMenuItem<ThemeMode>(
                  value: mode,
                  child: Text(_getThemeModeText(mode)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
