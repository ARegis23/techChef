// =================================================================
// 📁 ARQUIVO: lib/modules/profile/views/user_dashboard.dart
// =================================================================
// 👤 Painel de controle para o administrador gerenciar perfis.

import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Perfis'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_pin_outlined),
              title: const Text('Editar Meu Perfil'),
              subtitle: const Text('Altere suas informações pessoais'),
              onTap: () {
                // Navega para a tela de edição, passando os dados do admin
                // TODO: Passar os dados reais do usuário logado
                Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {'isFamilyMember': false});
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Adicionar Familiar'),
              subtitle: const Text('Cadastre um novo membro da família'),
              onTap: () {
                // Navega para a tela de edição em modo "adicionar familiar"
                Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {'isFamilyMember': true});
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Visualizar Família'),
              subtitle: const Text('Veja e gerencie os perfis cadastrados'),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.userFamilyView);
              },
            ),
          ),
        ],
      ),
    );
  }
}
