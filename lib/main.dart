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

void main() async {
  // Garanta que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialize o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Rode o App
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const TechChefApp(),
    ),);
}