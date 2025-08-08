// =================================================================
// 📁 ARQUIVO: lib/main.dart
// =================================================================
// 🎯 Ponto de entrada principal da aplicação.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../firebase_options.dart';
import '../app.dart';
import '../services/auth_service.dart';

void main() async {
  // Garanta que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialize o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Rode o App
  runApp(
    // MultiProvider para registrar todos os nossos serviços e provedores
    MultiProvider(
      providers: [
        // Provedor do serviço de autenticação
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        // Provedor para o tema
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const TechChefApp(),
    ),
  );
}