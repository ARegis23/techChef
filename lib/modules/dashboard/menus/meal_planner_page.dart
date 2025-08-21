// =================================================================
// 📁 ARQUIVO: lib/modules/menus/meal_planner_page.dart
// =================================================================
// 📅 Tela principal para visualizar e gerar o plano de refeições semanal.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/routes.dart';
import '../../../models/meal_plan_model.dart';
import '../../../models/shopping_list_model.dart';
import '../../../services/database_service.dart';
import '../../../services/meal_planner_service.dart';

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  late final DatabaseService _dbService;
  late final MealPlannerService _plannerService;
  final List<String> _weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService = DatabaseService(uid: user.uid);
      _plannerService = MealPlannerService(dbService: _dbService);
    }
  }
  
  Future<void> _generateMealPlan() async {
    setState(() => _isGenerating = true);
    final result = await _plannerService.generateWeeklyPlan();
    if (!mounted) return;

    if (result.success && result.generatedPlan != null) {
      // Se há ingredientes faltando, pergunta ao usuário o que fazer
      if (result.missingIngredients.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ingredientes Faltando'),
            content: Text(
              'O cardápio sugerido precisa dos seguintes ingredientes que não estão no seu estoque:\n\n- ${result.missingIngredients.join('\n- ')}\n\nDeseja adicioná-los à sua lista de compras?'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Salva o plano e fecha o diálogo
                  _dbService.upsertMealPlan(result.generatedPlan!);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cardápio salvo! Lembre-se de comprar os ingredientes.')),
                  );
                },
                child: const Text('Não, apenas salvar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Adiciona os ingredientes à lista de compras
                  for (final ingredientName in result.missingIngredients) {
                    final newItem = ShoppingListItem(
                      id: const Uuid().v4(),
                      name: ingredientName,
                      quantity: 1, // Quantidade padrão
                      unit: 'unidade(s)', // Unidade padrão
                      price: 0.0,
                    );
                    _dbService.upsertShoppingItem(newItem);
                  }
                  // Salva o plano e fecha o diálogo
                  _dbService.upsertMealPlan(result.generatedPlan!);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cardápio salvo e ingredientes adicionados à lista de compras!')),
                  );
                },
                child: const Text('Sim, adicionar'),
              ),
            ],
          ),
        );
      } else {
        // Se não há ingredientes faltando, apenas salva o plano
        await _dbService.upsertMealPlan(result.generatedPlan!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Novo cardápio semanal gerado e salvo!')),
        );
      }
    } else {
      // Se a geração falhou, mostra uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Ocorreu um erro ao gerar o cardápio.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Planejador Semanal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/planner_background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: StreamBuilder<MealPlan?>(
                  stream: _dbService.currentWeekMealPlanStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }

                    final mealPlan = snapshot.data;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: _isGenerating ? null : _generateMealPlan,
                            icon: _isGenerating 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isGenerating ? 'Gerando...' : 'Gerar Cardápio da Semana'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 3 / 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _weekDays.length,
                            itemBuilder: (context, index) {
                              final dayKey = DateFormat('EEEE').format(DateTime.now().add(Duration(days: index - DateTime.now().weekday + 1))).toLowerCase();
                              final dailyPlan = mealPlan?.dailyPlans[dayKey];
                              return _buildDayCard(_weekDays[index], dailyPlan);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String dayName, DailyMealPlan? dailyPlan) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildMealSlot('Café da Manhã', dailyPlan?.breakfastRecipeId),
                  _buildMealSlot('Almoço', dailyPlan?.lunchRecipeId),
                  _buildMealSlot('Lanches', dailyPlan?.snacksRecipeId),
                  _buildMealSlot('Jantar', dailyPlan?.dinnerRecipeId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSlot(String mealName, String? recipeId) {
    final bool isEmpty = recipeId == null;
    final recipeName = recipeId ?? 'Nenhuma receita selecionada';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            _getIconForMeal(mealName),
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: isEmpty ? null : () {
                // TODO: Navegar para a página de detalhes da receita
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ver detalhes da receita: $recipeId")));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mealName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    recipeName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                      color: isEmpty ? Colors.grey : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (isEmpty)
            IconButton(
              onPressed: () {
                // TODO: Abrir seletor de receitas para adicionar uma
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Adicionar receita para $mealName")));
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            ),
        ],
      ),
    );
  }

  IconData _getIconForMeal(String mealName) {
    switch (mealName) {
      case 'Café da Manhã': return Icons.free_breakfast_outlined;
      case 'Almoço': return Icons.lunch_dining_outlined;
      case 'Lanches': return Icons.bakery_dining_outlined;
      case 'Jantar': return Icons.dinner_dining_outlined;
      default: return Icons.restaurant_menu;
    }
  }
}
