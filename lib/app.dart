// =================================================================
// 📁 ARQUIVO: lib/app.dart
// =================================================================
// 🎯 Configura o núcleo do aplicativo, como tema e rotas.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/routes.dart';
import '../modules/auth/login.dart';
import '../modules/dashboard/dashboard.dart';
import '../modules/settings/settings.dart';
import '../modules/about/about.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';

class TechChefApp extends StatelessWidget {
  const TechChefApp({super.key});

  @override
  Widget build(BuildContext context) {

    // Escuta as mudanças no ThemeProvider.
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Tech Chef',

      // Use os temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // O Flutter vai escolher o tema automaticamente baseado na configuração do celular.
      // Podemos criar um seletor manual mais tarde.
      themeMode: themeProvider.themeMode,  

      // Configuração das rotas
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.dashboard: (context) => const DashboardPage(),
        AppRoutes.settings: (context) => const SettingsPage(),
        AppRoutes.about: (context) => const AboutPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
