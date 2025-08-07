// =================================================================
// 📁 ARQUIVO: lib/app.dart
// =================================================================
// 🎯 Configura o núcleo do aplicativo, como tema e rotas.

import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../modules/auth/login.dart';
import '../modules/dashboard/dashboard.dart';
import '../modules/settings/settings.dart';
import '../modules/about/about.dart';

class TechChefApp extends StatelessWidget {
  const TechChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tech Chef',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
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
