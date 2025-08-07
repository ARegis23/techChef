// =================================================================
// 📁 ARQUIVO: lib/modules/splash/splash_page.dart
// =================================================================
// ⏳ Tela de transição que verifica a autenticação do usuário.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/routes.dart';

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
    // Aguarda 5 segundos para simular o carregamento e melhorar a UX.
    await Future.delayed(const Duration(seconds: 3));

    // Garante que o widget ainda está na árvore de widgets antes de navegar.
    // Isso previne erros caso o usuário feche o app durante o delay.
    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Se o usuário já está logado (ex: sessão anterior com "Lembrar-me")
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
            Icon(
              Icons.soup_kitchen,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Tech Chef',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
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
