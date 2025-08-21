// =================================================================
// 📁 ARQUIVO: lib/services/database_service.dart
// =================================================================
// 🗄️ Serviço completo para gerenciar todas as operações com o Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/shopping_list_model.dart';
import '../models/user_model.dart';
import '../models/family_member_model.dart';
import '../models/recipe_model.dart';
import '../models/inventory_item_model.dart';

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
    String? imageUrl,
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
      'imageUrl': imageUrl,
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

  // --- MÉTODOS PARA RECEITAS ---
  CollectionReference get recipesCollection => userCollection.doc(uid).collection('recipes');

  Future<void> upsertRecipe(Recipe recipe) async {
    final docId = recipe.id == 'new' ? null : recipe.id;
    return await recipesCollection.doc(docId).set(recipe.toMap());
  }

  Future<void> deleteRecipe(String recipeId) async {
    return await recipesCollection.doc(recipeId).delete();
  }

  Stream<List<Recipe>> get recipesStream {
    return recipesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }

  // --- MÉTODOS PARA ESTOQUE ---
  CollectionReference get inventoryCollection => userCollection.doc(uid).collection('inventory');

  Future<void> upsertInventoryItem(InventoryItem item) async {
    final docId = item.id == 'new' ? null : item.id;
    return await inventoryCollection.doc(docId).set(item.toMap());
  }

  Future<void> deleteInventoryItem(String itemId) async {
    return await inventoryCollection.doc(itemId).delete();
  }

  Stream<List<InventoryItem>> get inventoryStream {
    return inventoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => InventoryItem.fromFirestore(doc)).toList();
    });
  }

  // --- MÉTODOS PARA LISTAS DE COMPRAS ---

  DocumentReference get activeShoppingListRef => userCollection.doc(uid).collection('shoppingLists').doc('active');
  CollectionReference get shoppingHistoryCollection => userCollection.doc(uid).collection('shoppingHistory');

  // CORREÇÃO: Sintaxe do Stream corrigida
  Stream<ShoppingList?> get activeShoppingListStream {
    return activeShoppingListRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ShoppingList.fromFirestore(snapshot);
    });
  }

  // CORREÇÃO: Sintaxe do Stream corrigida
  Stream<List<ShoppingList>> get shoppingHistoryStream {
    return shoppingHistoryCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ShoppingList.fromFirestore(doc)).toList();
    });
  }

  Future<void> upsertShoppingItem(ShoppingListItem item) async {
    await activeShoppingListRef.set({
      'name': 'Lista de Compras Ativa',
      'createdAt': FieldValue.serverTimestamp(),
      'items': {
        item.id: item.toMap(),
      }
    }, SetOptions(merge: true));
  }

  Future<void> deleteShoppingItem(String itemId) async {
    await activeShoppingListRef.update({
      'items.$itemId': FieldValue.delete(),
    });
  }

  Future<void> finalizeShopping(ShoppingList list, bool wasPartial) async {
    final batch = FirebaseFirestore.instance.batch();

    final historyDoc = shoppingHistoryCollection.doc();
    batch.set(historyDoc, {
      'name': 'Compra de ${DateFormat('dd/MM/yyyy').format(list.createdAt.toDate())} (${wasPartial ? 'Parcial' : 'Total'})',
      'createdAt': list.createdAt,
      'items': list.items.where((item) => item.isBought).fold<Map<String, dynamic>>({}, (prev, item) => prev..[item.id] = item.toMap()),
    });

    for (var item in list.items) {
      if (item.isBought) {
        final inventoryRef = inventoryCollection.doc();
        batch.set(inventoryRef, {
          'name': item.name,
          'quantity': item.quantity,
          'unit': item.unit,
          'lastPrice': item.price,
          'lastPurchaseDate': list.createdAt,
        });
      }
    }

    if (wasPartial) {
      final itemsToKeep = list.items.where((item) => !item.isBought).fold<Map<String, dynamic>>({}, (prev, item) => prev..[item.id] = item.toMap());
      batch.update(activeShoppingListRef, {'items': itemsToKeep});
    } else {
      batch.update(activeShoppingListRef, {'items': {}});
    }

    await batch.commit();
  }
}
