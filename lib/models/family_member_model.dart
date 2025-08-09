// =================================================================
// 📁 ARQUIVO: lib/models/family_member_model.dart
// =================================================================
// 👨‍👩‍👧‍👦 Modelo de dados para representar um familiar no Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final double? weight;
  final double? height;
  final Timestamp? birthDate;
  final String? imageUrl; // NOVO CAMPO para a foto do perfil

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    this.weight,
    this.height,
    this.birthDate,
    this.imageUrl,
  });

  // Converte um DocumentSnapshot do Firestore num objeto FamilyMember.
  factory FamilyMember.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FamilyMember(
      id: doc.id,
      name: data['name'] ?? '',
      relationship: data['relationship'] ?? '',
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      birthDate: data['birthDate'] as Timestamp?,
      imageUrl: data['imageUrl'],
    );
  }

  // Converte um objeto FamilyMember num mapa para salvar no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'weight': weight,
      'height': height,
      'birthDate': birthDate,
      'imageUrl': imageUrl,
    };
  }
}
