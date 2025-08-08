// =================================================================
// 📁 ARQUIVO: lib/modules/splash/views/splash_page.dart
// =================================================================
// ⏳ Tela de transição que verifica a autenticação e carrega as preferências.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/routes.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../services/database_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // Delay para UX

    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      if (user != null) {
        // Se o usuário está logado, carrega suas preferências
        final dbService = DatabaseService(uid: user.uid);
        final appUser = await dbService.getUserData();
        
        if (appUser != null) {
          // Aplica o tema salvo antes de navegar
          themeProvider.loadThemeFromString(appUser.themePreference);
        }
        
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      } else {
        // Se não há usuário logado, vai para a tela de login.
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.soup_kitchen, size: 100),
            const SizedBox(height: 24),
            Text('Tech Chef', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Carregando seu livro de receitas...'),
          ],
        ),
      ),
    );
  }
}
