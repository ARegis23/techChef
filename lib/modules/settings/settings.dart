// =================================================================
// 📁 ARQUIVO: lib/modules/settings/settings.dart
// =================================================================
// ⚙️ Tela de Configurações.

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Tema Escuro'),
            leading: const Icon(Icons.dark_mode),
            onTap: () {
              // Lógica para alterar o tema
            },
          ),
        ],
      ),
    );
  }
}
