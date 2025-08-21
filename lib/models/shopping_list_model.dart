// =================================================================
// 📁 ARQUIVO: lib/models/shopping_list_model.dart
// =================================================================
// 📦 Modelo de dados para a lista de compras e seus itens.

import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String id;
  final String name;
  final double price;
  final double quantity;
  final String unit;
  bool isBought;

  // =================================================================
  // 🔧 CAMPOS ADICIONADOS
  // =================================================================
  // Para carregar as informações da API junto com o item da lista.
  final String? barcode;
  final double? calories_100g;
  final double? proteins_100g;
  final double? carbs_100g;
  final double? fats_100g;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    this.isBought = false,
    // Adicionado ao construtor
    this.barcode,
    this.calories_100g,
    this.proteins_100g,
    this.carbs_100g,
    this.fats_100g,
  });

  factory ShoppingListItem.fromMap(String id, Map<String, dynamic> data) {
    return ShoppingListItem(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
      isBought: data['isBought'] ?? false,
      // Lendo os novos campos do Firestore
      barcode: data['barcode'],
      calories_100g: (data['calories_100g'] as num?)?.toDouble(),
      proteins_100g: (data['proteins_100g'] as num?)?.toDouble(),
      carbs_100g: (data['carbs_100g'] as num?)?.toDouble(),
      fats_100g: (data['fats_100g'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'isBought': isBought,
      // Adicionando os novos campos para salvar no Firestore
      'barcode': barcode,
      'calories_100g': calories_100g,
      'proteins_100g': proteins_100g,
      'carbs_100g': carbs_100g,
      'fats_100g': fats_100g,
    };
  }
}

class ShoppingList {
  final String id;
  final String name;
  final Timestamp createdAt;
  final List<ShoppingListItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.items,
  });

  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as Map<String, dynamic>? ?? {};
    final items = itemsData.entries.map((e) => ShoppingListItem.fromMap(e.key, e.value)).toList();
    
    // Ordena os itens para que os não comprados apareçam primeiro
    items.sort((a, b) {
      if (a.isBought && !b.isBought) return 1;
      if (!a.isBought && b.isBought) return -1;
      return 0;
    });

    return ShoppingList(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      items: items,
    );
  }
}
