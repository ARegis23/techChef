// =================================================================
// 📁 ARQUIVO: lib/models/shopping_list_model.dart
// =================================================================
// 🛒 Modelos de dados para representar uma Lista de Compras e os seus itens.

import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String id;
  String name;
  double price;
  double quantity;
  String unit;
  bool isBought;

  ShoppingListItem({
    required this.id,
    required this.name,
    this.price = 0.0,
    this.quantity = 1.0,
    required this.unit,
    this.isBought = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'quantity': quantity,
    'unit': unit,
    'isBought': isBought,
  };

  factory ShoppingListItem.fromMap(String id, Map<String, dynamic> map) {
    return ShoppingListItem(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'unidade(s)',
      isBought: map['isBought'] ?? false,
    );
  }
}

class ShoppingList {
  final String id;
  String name;
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
    
    return ShoppingList(
      id: doc.id,
      name: data['name'] ?? 'Lista de Compras',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      items: items,
    );
  }
}
