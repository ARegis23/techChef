// =================================================================
// 📁 ARQUIVO: lib/modules/dashboard/dashboard.dart
// =================================================================
// 📊 Tela principal com layout responsivo, imagem de fundo e navegação controlada.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  Future<AppUser?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userFuture = DatabaseService(uid: user.uid).getUserData();
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await _authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope desabilita o botão de "voltar" do dispositivo/navegador nesta tela.
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // extendBodyBehindAppBar permite que o corpo da tela fique atrás da AppBar.
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Tech Chef'),
          // Deixa a AppBar transparente para ver a imagem de fundo.
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Configurações',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _signOut(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Camada 1: Imagem de Fundo
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  // IMPORTANTE: Adicione uma imagem em 'assets/dashboard_background.png'
                  image: const AssetImage('assets/dashboard_background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), // Escurece a imagem para melhor contraste
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            // Camada 2: Conteúdo Principal
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<AppUser?>(
                      future: _userFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Carregando...', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white));
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return Text('Olá, ${snapshot.data!.name}!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white));
                        }
                        return const Text('Bem-vindo!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white));
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text('O que vamos planejar hoje?', style: TextStyle(fontSize: 18, color: Colors.white70)),
                    const SizedBox(height: 32),
                    // LayoutBuilder para criar a grade responsiva
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2; // Padrão para telas médias
                        if (constraints.maxWidth > 1100) {
                          crossAxisCount = 4; // Telas grandes
                        } else if (constraints.maxWidth < 600) {
                          crossAxisCount = 1; // Telas pequenas (celular)
                        }
                        
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.2, // Ajusta a proporção dos cards
                          children: [
                            _buildFeatureCard(context, icon: Icons.groups_outlined, label: 'Perfis', color: Colors.blue.shade300, onTap: () => Navigator.of(context).pushNamed(AppRoutes.userDashboard)),
                            _buildFeatureCard(context, icon: Icons.restaurant_menu_outlined, label: 'Cardápios', color: Colors.orange.shade300, onTap: () => Navigator.of(context).pushNamed(AppRoutes.menus)),
                            _buildFeatureCard(context, icon: Icons.shopping_cart_outlined, label: 'Compras', color: Colors.green.shade300, onTap: () => Navigator.of(context).pushNamed(AppRoutes.shoppingList)),
                            _buildFeatureCard(context, icon: Icons.inventory_2_outlined, label: 'Estoque', color: Colors.purple.shade300, onTap: () => Navigator.of(context).pushNamed(AppRoutes.inventory)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Card(
      // A aparência do card agora é controlada pelo CardTheme
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
