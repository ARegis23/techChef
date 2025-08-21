// =================================================================
// 📁 ARQUIVO: lib/services/open_food_facts_service.dart
// =================================================================
// 📡 Serviço para comunicar com a API da Open Food Facts.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item_model.dart';

class OpenFoodFactsService {
  final String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';

  // O método agora retorna diretamente um Future<InventoryItem?>
  Future<InventoryItem?> getProductByBarcode(String barcode) async {
    final url = Uri.parse('$_baseUrl$barcode.json');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          // Produto encontrado, traduz o JSON diretamente para o nosso modelo InventoryItem
          final productData = data['product'];
          final nutriments = productData['nutriments'] as Map<String, dynamic>? ?? {};

          return InventoryItem(
            id: 'api_temp', // ID temporário, pois ainda não está no nosso DB
            name: productData['product_name'] ?? 'Nome não encontrado',
            quantity: 0, // Quantidade inicial padrão
            unit: 'unidade(s)', // Unidade inicial padrão
            barcode: data['code'] ?? '',
            imageUrl: productData['image_url'],
            calories_100g: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
            proteins_100g: (nutriments['proteins_100g'] as num?)?.toDouble(),
            carbs_100g: (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
            fats_100g: (nutriments['fat_100g'] as num?)?.toDouble(),
          );
        } else {
          print('Produto com código de barras $barcode não encontrado na Open Food Facts.');
          return null;
        }
      } else {
        print('Erro na API Open Food Facts: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar à API Open Food Facts: $e');
      return null;
    }
  }
}
