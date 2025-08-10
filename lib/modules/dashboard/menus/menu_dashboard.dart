// =================================================================
// 📁 ARQUIVO: lib/modules/menus/menus_page.dart
// =================================================================
// 🍽️ Central de navegação para o Livro de Receitas e o Planejador Semanal.

import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class MenusPage extends StatelessWidget {
  const MenusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cardápios e Receitas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Imagem de Fundo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('menus_background.png'),
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800), // Limita a largura máxima
                  child: Wrap(
                    // O Wrap organiza os itens automaticamente
                    spacing: 24.0, // Espaçamento horizontal entre os cards
                    runSpacing: 24.0, // Espaçamento vertical quando os cards quebram a linha
                    alignment: WrapAlignment.center,
                    children: [
                      _buildOptionCard(
                        context,
                        icon: Icons.menu_book,
                        title: 'Livro de Receitas',
                        subtitle: 'Veja, adicione e edite as suas receitas',
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.recipeBook);
                        },
                      ),
                      _buildOptionCard(
                        context,
                        icon: Icons.calendar_month,
                        title: 'Planejador Semanal',
                        subtitle: 'Organize as refeições da sua semana',
                        onTap: () {
                          // Navigator.of(context).pushNamed(AppRoutes.mealPlanner);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funcionalidade em breve!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    // Definimos uma largura para os cards para que o Wrap funcione bem
    return SizedBox(
      width: 350,
      child: Card(
        child: ListTile(
          leading: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        ),
      ),
    );
  }
}
