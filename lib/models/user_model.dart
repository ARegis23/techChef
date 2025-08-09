// =================================================================
// 📁 ARQUIVO: lib/models/user_model.dart
// =================================================================
// 📦 Modelo de dados para representar um utilizador (admin) no Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String themePreference;
  // Campos adicionais para o admin
  final double? weight;
  final double? height;
  final Timestamp? birthDate;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.themePreference = 'system',
    this.weight,
    this.height,
    this.birthDate,
  });

  // Converte um DocumentSnapshot do Firestore num objeto AppUser.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      themePreference: data['themePreference'] ?? 'system',
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      birthDate: data['birthDate'] as Timestamp?,
    );
  }
}
