// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_family_view.dart
// =================================================================
// 👨‍👩‍👧‍👦 Tela para visualizar a lista de familiares cadastrados.

import 'package:flutter/material.dart';
import '../../../../core/routes.dart';

class UserFamilyViewPage extends StatelessWidget {
  const UserFamilyViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Substituir por uma lista real vinda do Firebase
    final mockFamily = [
      {'name': 'Jane Doe', 'relationship': 'Cônjuge'},
      {'name': 'John Doe Jr.', 'relationship': 'Filho(a)'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Família'),
      ),
      body: ListView.builder(
        itemCount: mockFamily.length,
        itemBuilder: (context, index) {
          final member = mockFamily[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(member['name']!),
              subtitle: Text(member['relationship']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      // Navega para a tela de edição, passando os dados do familiar
                      Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {
                        'isFamilyMember': true,
                        // 'user': member, // TODO: Passar o objeto real do usuário
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: () {
                      // TODO: Implementar lógica de exclusão com confirmação
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {'isFamilyMember': true});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
