// =================================================================
// 📁 ARQUIVO: lib/services/open_food_facts_service.dart
// =================================================================
// 📡 Serviço para comunicar com a API da Open Food Facts.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item_model.dart';

class OpenFoodFactsService {
  final String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';

  Future<InventoryItem?> getProductByBarcode(String barcode) async {
    final url = Uri.parse('$_baseUrl$barcode.json');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final productData = data['product'];
          final nutriments = productData['nutriments'] as Map<String, dynamic>? ?? {};

          return InventoryItem(
            id: 'api_temp',
            name: productData['product_name'] ?? 'Nome não encontrado',
            quantity: 0,
            unit: 'unidade(s)',
            barcode: data['code'] ?? '',
            imageUrl: productData['image_url'],
            calories_100g: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
            proteins_100g: (nutriments['proteins_100g'] as num?)?.toDouble(),
            carbs_100g: (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
            fats_100g: (nutriments['fat_100g'] as num?)?.toDouble(),
          );
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao conectar à API Open Food Facts: $e');
      return null;
    }
  }
}
