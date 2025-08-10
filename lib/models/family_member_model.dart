// =================================================================
// 📁 ARQUIVO: lib/models/family_member_model.dart
// =================================================================
// 👨‍👩‍👧‍👦 Modelo de dados para representar um familiar no Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final String? imageUrl;
  
  // Campos de saúde
  final double? weight;
  final double? height;
  final Timestamp? birthDate;
  final String? gender;
  final String? transitioningTo;
  final String? activityLevel;
  final String? goal;
  final List<String>? conditions;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
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

  factory FamilyMember.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FamilyMember(
      id: doc.id,
      name: data['name'] ?? '',
      relationship: data['relationship'] ?? '',
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'imageUrl': imageUrl,
      'weight': weight,
      'height': height,
      'birthDate': birthDate,
      'gender': gender,
      'transitioningTo': transitioningTo,
      'activityLevel': activityLevel,
      'goal': goal,
      'conditions': conditions,
    };
  }
}
