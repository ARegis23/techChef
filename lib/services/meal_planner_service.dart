// =================================================================
// 📁 ARQUIVO: lib/services/meal_planner_service.dart
// =================================================================
// 🧠 O cérebro do app: Serviço para gerar planos de refeições inteligentes.

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item_model.dart';
import '../models/meal_plan_model.dart';
import '../models/recipe_model.dart';
import 'database_service.dart';
import 'recipe_api_service.dart'; // Importa o novo serviço de API

/// Classe de resultado para encapsular a resposta da geração do plano.
class MealPlanGenerationResult {
  final bool success;
  final MealPlan? generatedPlan;
  final List<String> missingIngredients;
  final String? errorMessage;

  MealPlanGenerationResult({
    required this.success,
    this.generatedPlan,
    this.missingIngredients = const [],
    this.errorMessage,
  });
}

class MealPlannerService {
  final DatabaseService dbService;
  // Adiciona o novo serviço de API
  final RecipeApiService _recipeApiService = RecipeApiService();

  MealPlannerService({required this.dbService});

  /// Gera um plano de refeições para a semana com base nas receitas e no estoque.
  Future<MealPlanGenerationResult> generateWeeklyPlan() async {
    try {
      // 1. Obter os dados necessários
      final List<Recipe> localRecipes = await dbService.recipesStream.first;
      final List<InventoryItem> inventory = await dbService.inventoryStream.first;
      
      List<Recipe> availableRecipes = List.from(localRecipes);

      // Se o usuário tiver poucas receitas, busca mais online
      if (availableRecipes.length < 15) {
        try {
          // TODO: Futuramente, passar preferências do usuário (restrições, etc.)
          final apiRecipes = await _recipeApiService.searchRecipes(number: 20 - availableRecipes.length);
          availableRecipes.addAll(apiRecipes);
        } catch (e) {
          print("Não foi possível buscar receitas da API, continuando com as locais. Erro: $e");
        }
      }

      // Remove duplicatas caso a API retorne uma receita já salva localmente
      final uniqueRecipes = { for (var r in availableRecipes) r.id: r }.values.toList();
      
      // Verifica novamente se há receitas suficientes para começar
      if (uniqueRecipes.length < 4) {
        return MealPlanGenerationResult(
          success: false,
          errorMessage: 'Não foi possível encontrar receitas suficientes, mesmo buscando online. Tente cadastrar mais algumas receitas manualmente.',
        );
      }

      final random = Random();
      final dailyPlans = <String, DailyMealPlan>{};
      final missingIngredients = <String>{}; // Usamos um Set para não ter ingredientes duplicados
      final inventoryNames = inventory.map((item) => item.name.toLowerCase()).toSet();

      final weekDayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

      for (final dayKey in weekDayKeys) {
        // 2. Lógica de Geração (Simplificada)
        // Seleciona 4 receitas aleatórias para o dia da lista de receitas disponíveis
        final dailyRecipes = <Recipe>[];
        while (dailyRecipes.length < 4) {
          dailyRecipes.add(uniqueRecipes[random.nextInt(uniqueRecipes.length)]);
        }

        // 3. Verifica os ingredientes de cada receita contra o estoque
        for (final recipe in dailyRecipes) {
          for (final ingredient in recipe.ingredients) {
            // Uma verificação simples se o nome do ingrediente está contido no nome de algum item do estoque
            final foundInInventory = inventoryNames.any((inventoryItemName) => inventoryItemName.contains(ingredient.name.toLowerCase()));
            if (!foundInInventory) {
              missingIngredients.add(ingredient.name);
            }
          }
        }
        
        dailyPlans[dayKey] = DailyMealPlan(
          breakfastRecipeId: dailyRecipes[0].id,
          lunchRecipeId: dailyRecipes[1].id,
          snacksRecipeId: dailyRecipes[2].id,
          dinnerRecipeId: dailyRecipes[3].id,
        );
      }

      // 4. Monta o objeto final do plano de refeições
      final now = DateTime.now();
      // Garante que a data de início seja sempre a última segunda-feira
      final startDate = now.subtract(Duration(days: now.weekday - 1));
      final plan = MealPlan(
        id: dbService.getWeekId(now),
        startDate: Timestamp.fromDate(startDate),
        dailyPlans: dailyPlans,
      );

      return MealPlanGenerationResult(
        success: true,
        generatedPlan: plan,
        missingIngredients: missingIngredients.toSet().toList(), // Garante que não haja duplicatas
      );

    } catch (e) {
      return MealPlanGenerationResult(
        success: false,
        errorMessage: 'Ocorreu um erro inesperado ao gerar o cardápio: $e',
      );
    }
  }
}
