// =================================================================
// 📁 ARQUIVO: lib/models/inventory_item_model.dart
// =================================================================
// 📦 Modelo de dados para representar um item no estoque do utilizador.

import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
