// =================================================================
// 📁 ARQUIVO: lib/main.dart
// =================================================================
// 🎯 Ponto de entrada principal da aplicação.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Importa o pacote
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../firebase_options.dart';
import '../app.dart';
import '../services/auth_service.dart';

Future<void> main() async {
  // Garanta que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // =================================================================
  // ✨ LÓGICA ADICIONADA
  // =================================================================
  // 2. Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");

  // 3. Inicializa o Firebase (removida a chamada duplicada)
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
