// =================================================================
// 📁 ARQUIVO: lib/app.dart
// =================================================================
// 🎯 Configura o núcleo do aplicativo, como tema e rotas.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/routes.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/route_generator.dart';

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

      // Define o tema atual baseado no ThemeProvider
      themeMode: themeProvider.themeMode,  

      // Define a tela de splash como a rota inicial
      initialRoute: AppRoutes.splash, 

      // Configuração das rotas
      onGenerateRoute: RouteGenerator.generateRoute,

      // Trate rotas desconhecidas
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Erro de Rota')),
          body: Center(child: Text('Rota não encontrada: ${settings.name}')),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
