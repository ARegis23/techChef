// =================================================================
// 📁 ARQUIVO: lib/modules/dashboard/dashboard.dart
// =================================================================
// 📊 Tela principal após o login.

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import '../../core/routes.dart';
import '../../services/auth_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // 3. Crie a função de logout
  Future<void> _signOut(BuildContext context) async {
    final authService = AuthService();
    await GoogleSignIn().signOut(); 
    await authService.signOut();  
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao seu painel!',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.about);
              },
              child: const Text('Sobre o App'),
            ),
            const SizedBox(height: 10),
            // 4. Chame a nova função de logout
            TextButton(
              onPressed: () => _signOut(context),
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
