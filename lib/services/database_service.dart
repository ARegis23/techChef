// =================================================================
// 📁 ARQUIVO: lib/services/database_service.dart
// =================================================================
// 🗄️ Serviço para gerenciar operações com o Firestore, agora com Streams.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import '../models/user_model.dart';
import '../models/family_member_model.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // --- MÉTODOS DE UTILIZADOR ---
  Future<void> updateUserData(String name, String email, {String theme = 'system'}) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'themePreference': theme,
    });
  }

  Future<void> updateAdminProfile({
    required String name,
    String? imageUrl, // NOVO PARÂMETRO
    double? weight,
    double? height,
    Timestamp? birthDate,
    String? gender,
    String? transitioningTo,
    String? activityLevel,
    String? goal,
    List<String>? conditions,
  }) async {
    if (uid == null) return;
    return await userCollection.doc(uid).update({
      'name': name,
      'imageUrl': imageUrl, // NOVO CAMPO
      'weight': weight,
      'height': height,
      'birthDate': birthDate,
      'gender': gender,
      'transitioningTo': transitioningTo,
      'activityLevel': activityLevel,
      'goal': goal,
      'conditions': conditions,
    });
  }
  
  Future<void> updateUserThemePreference(String themePreference) async {
    if (uid == null) return;
    return await userCollection.doc(uid).update({'themePreference': themePreference});
  }

  Future<AppUser?> getUserData() async {
    try {
      DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch(e) {
      print(e);
      return null;
    }
  }

  // --- MÉTODOS PARA FAMILIARES ---
  CollectionReference get familyCollection => userCollection.doc(uid).collection('family');

  Future<void> upsertFamilyMember(FamilyMember member) async {
    final docId = member.id == 'new' ? null : member.id;
    return await familyCollection.doc(docId).set(member.toMap());
  }

  Future<void> deleteFamilyMember(String memberId) async {
    return await familyCollection.doc(memberId).delete();
  }

  Stream<List<FamilyMember>> get familyStream {
    return familyCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FamilyMember.fromFirestore(doc)).toList();
    });
  }

  // --- NOVOS MÉTODOS PARA RECEITAS ---

  // Referência para a subcoleção 'recipes' dentro do documento do utilizador.
  CollectionReference get recipesCollection => userCollection.doc(uid).collection('recipes');

  // Adiciona ou atualiza uma receita.
  Future<void> upsertRecipe(Recipe recipe) async {
    final docId = recipe.id == 'new' ? null : recipe.id;
    return await recipesCollection.doc(docId).set(recipe.toMap());
  }

  // Exclui uma receita.
  Future<void> deleteRecipe(String recipeId) async {
    return await recipesCollection.doc(recipeId).delete();
  }

  // Fornece um fluxo de dados em tempo real da lista de receitas.
  Stream<List<Recipe>> get recipesStream {
    return recipesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }
}
