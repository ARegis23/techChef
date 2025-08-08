// =================================================================
// 📁 ARQUIVO: lib/models/user_model.dart
// =================================================================
// 📦 Modelo de dados para representar um usuário no Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String themePreference; // 'light', 'dark', ou 'system'

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.themePreference = 'system',
  });

  // Converte um objeto AppUser em um mapa para salvar no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'themePreference': themePreference,
    };
  }

  // Cria um objeto AppUser a partir de um DocumentSnapshot do Firestore.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      themePreference: data['themePreference'] ?? 'system',
    );
  }
}
