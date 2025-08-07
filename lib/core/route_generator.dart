// =================================================================
// 📁 ARQUIVO: lib/core/navigation/route_generator.dart
// =================================================================
// 🚦 Controla a criação de todas as rotas, aplicando uma tela de
//    carregamento entre as transições de página.

import 'package:flutter/material.dart';

import '../modules/about/about.dart';
import '../modules/auth/login.dart';
import '../modules/dashboard/dashboard.dart';
import '../modules/settings/settings.dart';
import '../modules/splash/splash_page.dart';
import 'routes.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // A tela de Splash é um caso especial, ela não deve ter um carregamento antes de si mesma.
    if (settings.name == AppRoutes.splash) {
      return MaterialPageRoute(builder: (_) => const SplashPage());
    }

    // Para todas as outras rotas, nós retornamos uma rota que primeiro
    // constrói uma tela de carregamento temporária.
    return MaterialPageRoute(
      builder: (context) => FutureBuilder(
        // Usamos um Future.delayed para simular o carregamento de dados.
        // Um tempo curto (500ms) é ideal para não prejudicar a experiência do usuário.
        future: Future.delayed(const Duration(milliseconds: 500)),
        builder: (context, snapshot) {
          // Enquanto o delay está ativo, mostramos uma tela de carregamento.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Preparando a próxima tela...'),
                  ],
                ),
              ),
            );
          }

          // Quando o delay termina, construímos a página de destino real.
          return _buildPage(settings);
        },
      ),
      settings: settings, // É importante passar os settings para a nova rota.
    );
  }

  // Função auxiliar para obter o widget da página com base no nome da rota.
  static Widget _buildPage(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return const LoginPage();
      case AppRoutes.dashboard:
        return const DashboardPage();
      case AppRoutes.settings:
        return const SettingsPage();
      case AppRoutes.about:
        return const AboutPage();
      default:
        // Rota de erro caso a página não seja encontrada.
        return Scaffold(
          appBar: AppBar(title: const Text('Erro')),
          body: const Center(child: Text('Página não encontrada')),
        );
    }
  }
}
