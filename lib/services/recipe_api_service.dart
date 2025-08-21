// =================================================================
// 📁 ARQUIVO: lib/services/recipe_api_service.dart
// =================================================================
// 🌐 Serviço para buscar receitas de uma API externa como a Spoonacular.

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa o pacote dotenv
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/recipe_model.dart';

class RecipeApiService {
  // =================================================================
  // 🔧 CORRIGIDO: Carrega a chave da API de forma segura do .env
  // =================================================================
  // Certifique-se de que seu arquivo .env tenha a linha:
  // SPOONACULAR_API_KEY=suaChaveDeApiReal
  final String? _apiKey = dotenv.env['SPOONACULAR_API_KEY'];
  final String _baseUrl = 'https://api.spoonacular.com/recipes/complexSearch';

  /// Busca receitas de uma API externa com base em vários critérios.
  Future<List<Recipe>> searchRecipes({
    int number = 10, // Quantidade de receitas a buscar
    String? diet, // Ex: 'vegetarian', 'vegan', 'gluten-free'
    String? cuisine, // Ex: 'italian', 'mexican'
  }) async {
    // Se a chave não for encontrada no .env, a busca online é ignorada.
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('AVISO: A variável SPOONACULAR_API_KEY não foi encontrada no seu arquivo .env. A busca online será ignorada.');
      return [];
    }

    // Monta a URL com os parâmetros
    final queryParameters = {
      'apiKey': _apiKey!,
      'number': number.toString(),
      'addRecipeInformation': 'true', // Para incluir ingredientes e instruções
      'fillIngredients': 'true', // Para incluir informações detalhadas dos ingredientes
      if (diet != null) 'diet': diet,
      if (cuisine != null) 'cuisine': cuisine,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];

        // Converte os resultados da API para o nosso modelo de Recipe
        return results.map((recipeData) => _convertApiDataToRecipe(recipeData)).toList();
      } else {
        print('Erro na API de Receitas: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro ao conectar à API de Receitas: $e');
      return [];
    }
  }

  /// Converte o JSON de um resultado da API para o nosso modelo Recipe.
  Recipe _convertApiDataToRecipe(Map<String, dynamic> data) {
    // Extrai os ingredientes
    final ingredientsList = (data['extendedIngredients'] as List<dynamic>? ?? [])
        .map((ing) => Ingredient(
              name: ing['nameClean'] ?? ing['name'] ?? '',
              quantity: (ing['amount'] as num?)?.toDouble() ?? 0.0,
              unit: ing['unit'] ?? '',
            ))
        .toList();

    // Extrai as instruções
    final instructionsList = (data['analyzedInstructions'] as List<dynamic>? ?? [])
        .expand((instr) => (instr['steps'] as List<dynamic>? ?? []))
        .map((step) => (step['step'] as String?) ?? '')
        .toList();

    return Recipe(
      // Usamos o ID da API como ID, mas convertido para String
      id: data['id']?.toString() ?? const Uuid().v4(),
      name: data['title'] ?? 'Receita sem nome',
      ingredients: ingredientsList,
      instructions: instructionsList,
      prepTime: data['preparationMinutes'] ?? 0,
      cookTime: data['cookingMinutes'] ?? 0,
      servings: data['servings'] ?? 0,
      imageUrl: data['image'],
      isPublic: true, // Receitas da API são consideradas públicas
    );
  }
}
