// =================================================================
// 📁 ARQUIVO: lib/modules/auth/verify_email_page.dart
// =================================================================
// 📧 Tela para instruir o usuário a verificar seu e-mail após o cadastro.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/routes.dart';
import '../../../services/auth_service.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AuthService _authService = AuthService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inicia um timer para verificar o status do e-mail a cada 5 segundos.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _authService.refreshUser();
      if (_authService.isEmailVerified()) {
        timer.cancel(); // Para o timer
        // Navega para a dashboard quando o e-mail for verificado.
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Garante que o timer seja cancelado ao sair da tela.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'seu e-mail';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifique seu E-mail'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.email_outlined, size: 80),
              const SizedBox(height: 24),
              Text(
                'Um e-mail de verificação foi enviado para:\n$userEmail',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                'Por favor, clique no link enviado para ativar sua conta. Esta página será atualizada automaticamente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Reenviar E-mail'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser?.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('E-mail de verificação reenviado!')),
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  _authService.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                },
                child: const Text('Cancelar e voltar ao Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
