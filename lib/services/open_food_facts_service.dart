// =================================================================
// 📁 ARQUIVO: lib/services/open_food_facts_service.dart
// =================================================================
// 📡 Serviço para comunicar com a API da Open Food Facts.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item_model.dart';

class OpenFoodFactsService {
  final String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';

  // =================================================================
  // 💡 FUNÇÃO AUXILIAR ADICIONADA
  // =================================================================
  // Esta função converte um valor da API (que pode ser String, int, double ou null)
  // para um double de forma segura.
  double? _parseNutriment(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<InventoryItem?> getProductByBarcode(String barcode) async {
    final url = Uri.parse('$_baseUrl$barcode.json');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final productData = data['product'];
          final nutriments = productData['nutriments'] as Map<String, dynamic>? ?? {};

          print('DADOS NUTRICIONAIS RECEBIDOS: $nutriments'); 

          // =================================================================
          // 🔧 CORREÇÃO APLICADA
          // =================================================================
          // Agora usamos a função _parseNutriment para garantir que os dados
          // sejam convertidos corretamente, não importa o formato.
          return InventoryItem(
            id: 'api_temp',
            name: productData['product_name_pt'] ?? productData['product_name'] ?? 'Nome não encontrado',
            quantity: 0,
            unit: 'unidade(s)',
            barcode: data['code'] ?? '',
            imageUrl: productData['image_url'],
            calories_100g: _parseNutriment(nutriments['energy-kcal_100g']),
            proteins_100g: _parseNutriment(nutriments['proteins_100g']),
            carbs_100g: _parseNutriment(nutriments['carbohydrates_100g']),
            fats_100g: _parseNutriment(nutriments['fat_100g']),
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
