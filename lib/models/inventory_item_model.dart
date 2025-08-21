// =================================================================
// 📁 ARQUIVO: lib/models/inventory_item_model.dart
// =================================================================
// 📦 Modelo de dados unificado para um item no estoque do utilizador.

import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  
  // Informações do produto (da API ou manuais)
  final String? barcode;
  final String? imageUrl;
  
  // Informações da última compra
  final double? lastPrice;
  final Timestamp? lastPurchaseDate;

  // Informações nutricionais (por 100g/ml)
  final double? calories_100g;
  final double? proteins_100g;
  final double? carbs_100g;
  final double? fats_100g;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.barcode,
    this.imageUrl,
    this.lastPrice,
    this.lastPurchaseDate,
    this.calories_100g,
    this.proteins_100g,
    this.carbs_100g,
    this.fats_100g,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
      barcode: data['barcode'],
      imageUrl: data['imageUrl'],
      lastPrice: (data['lastPrice'] as num?)?.toDouble(),
      lastPurchaseDate: data['lastPurchaseDate'] as Timestamp?,
      calories_100g: (data['calories_100g'] as num?)?.toDouble(),
      proteins_100g: (data['proteins_100g'] as num?)?.toDouble(),
      carbs_100g: (data['carbs_100g'] as num?)?.toDouble(),
      fats_100g: (data['fats_100g'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'lastPrice': lastPrice,
      'lastPurchaseDate': lastPurchaseDate,
      'calories_100g': calories_100g,
      'proteins_100g': proteins_100g,
      'carbs_100g': carbs_100g,
      'fats_100g': fats_100g,
    };
  }
}
