// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_dashboard.dart
// =================================================================
// 👤 Painel de controle para o administrador gerir perfis, com novo design responsivo.

import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cuidando dos Cadastros'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Imagem de Fundo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/perfil_background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Conteúdo
              SafeArea(
                // 1. Usamos um LayoutBuilder aqui para obter a altura da viewport
                child: LayoutBuilder(
                  builder: (context, viewportConstraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        // 2. Usamos um ConstrainedBox para definir a altura mínima
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight - (24.0 * 2), // Subtrai o padding vertical
                        ),
                        // 3. Agora a Column ocupa a altura da tela, e podemos centralizá-la
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // <-- Centraliza verticalmente
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 4. Seu LayoutBuilder e GridView entram aqui dentro, sem alterações
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount = 3;
                                if (constraints.maxWidth > 1100) {
                                  crossAxisCount = 3;
                                } else if (constraints.maxWidth < 600) {
                                  crossAxisCount = 1;
                                }

                                return GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 1.2,
                                  children: [
                                    _buildOptionCard(
                                      context,
                                      icon: Icons.person,
                                      title: 'Editar Meu Perfil',
                                      subtitle: 'Altere as suas informações pessoais',
                                      onTap: () {
                                        Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {'isFamilyMember': false});
                                      },
                                    ),
                                    _buildOptionCard(
                                      context,
                                      icon: Icons.group_add_outlined,
                                      title: 'Adicionar Familiar',
                                      subtitle: 'Cadastre um novo membro da família',
                                      onTap: () {
                                        Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {'isFamilyMember': true});
                                      },
                                    ),
                                    _buildOptionCard(
                                      context,
                                      icon: Icons.groups_outlined,
                                      title: 'Visualizar Família',
                                      subtitle: 'Veja e gerencie os perfis cadastrados',
                                      onTap: () {
                                        Navigator.of(context).pushNamed(AppRoutes.userFamilyView);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        
      );
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    // Definimos uma largura para os cards para que o Wrap funcione bem
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
