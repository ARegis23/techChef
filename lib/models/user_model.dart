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
  final String? imageUrl; // NOVO CAMPO para a foto de perfil do admin
  
  // Campos de saúde
  final double? weight;
  final double? height;
  final Timestamp? birthDate;
  final String? gender;
  final String? transitioningTo;
  final String? activityLevel;
  final String? goal;
  final List<String>? conditions;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.themePreference = 'system',
    this.imageUrl,
    this.weight,
    this.height,
    this.birthDate,
    this.gender,
    this.transitioningTo,
    this.activityLevel,
    this.goal,
    this.conditions,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      themePreference: data['themePreference'] ?? 'system',
      imageUrl: data['imageUrl'],
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      birthDate: data['birthDate'] as Timestamp?,
      gender: data['gender'],
      transitioningTo: data['transitioningTo'],
      activityLevel: data['activityLevel'],
      goal: data['goal'],
      conditions: List<String>.from(data['conditions'] ?? []),
    );
  }
}
