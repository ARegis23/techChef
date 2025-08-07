// =================================================================
// 📁 ARQUIVO: lib/main.dart
// =================================================================
// 🎯 Ponto de entrada principal da aplicação.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Importe o dotenv
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  // Garanta que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carregue as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");

  // 3. Inicialize o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Rode o App
  runApp(const TechChefApp());
}