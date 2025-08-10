// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/inventory_page.dart
// =================================================================
// 📦 Central de navegação para a gestão de estoque e histórico de compras.

import 'package:flutter/material.dart';
import '../../../core/routes.dart';


class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gestão de Estoque'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Imagem de Fundo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/dashboard_background.png'), // Reutilizamos a imagem do dashboard
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
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Wrap(
                    spacing: 24.0,
                    runSpacing: 24.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildOptionCard(
                        context,
                        icon: Icons.inventory_2_outlined,
                        title: 'Meu Estoque',
                        subtitle: 'Veja e atualize os seus itens',
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.inventoryList);
                        },
                      ),
                      _buildOptionCard(
                        context,
                        icon: Icons.history_edu_outlined,
                        title: 'Histórico de Compras',
                        subtitle: 'Consulte as suas compras passadas',
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.purchaseHistory);
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