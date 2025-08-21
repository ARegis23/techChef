// =================================================================
// 📁 ARQUIVO: lib/models/meal_plan_model.dart
// =================================================================
// 📦 Modelos de dados para o Planejador de Refeições.

import 'package:cloud_firestore/cloud_firestore.dart';

// -----------------------------------------------------------------
// Representa as refeições para um único dia.
// -----------------------------------------------------------------
class DailyMealPlan {
  final String? breakfastRecipeId; // ID da receita para o café da manhã
  final String? lunchRecipeId;     // ID da receita para o almoço
  final String? dinnerRecipeId;    // ID da receita para o jantar
  final String? snacksRecipeId;    // ID da receita para os lanches
  final String? notes;             // Anotações opcionais para o dia

  DailyMealPlan({
    this.breakfastRecipeId,
    this.lunchRecipeId,
    this.dinnerRecipeId,
    this.snacksRecipeId,
    this.notes,
  });

  // Converte um mapa do Firestore para um objeto DailyMealPlan
  factory DailyMealPlan.fromMap(Map<String, dynamic> data) {
    return DailyMealPlan(
      breakfastRecipeId: data['breakfastRecipeId'],
      lunchRecipeId: data['lunchRecipeId'],
      dinnerRecipeId: data['dinnerRecipeId'],
      snacksRecipeId: data['snacksRecipeId'],
      notes: data['notes'],
    );
  }

  // Converte o objeto DailyMealPlan para um mapa para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'breakfastRecipeId': breakfastRecipeId,
      'lunchRecipeId': lunchRecipeId,
      'dinnerRecipeId': dinnerRecipeId,
      'snacksRecipeId': snacksRecipeId,
      'notes': notes,
    };
  }
}

// -----------------------------------------------------------------
// Representa o plano de refeições completo para uma semana.
// -----------------------------------------------------------------
class MealPlan {
  final String id; // Ex: '2025-W34' (Semana 34 de 2025)
  final Timestamp startDate; // Data de início da semana (a segunda-feira)
  
  // Um mapa para guardar o plano de cada dia da semana
  final Map<String, DailyMealPlan> dailyPlans; // Keys: 'monday', 'tuesday', etc.

  MealPlan({
    required this.id,
    required this.startDate,
    required this.dailyPlans,
  });

  // Converte um documento do Firestore para um objeto MealPlan
  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final plansData = data['dailyPlans'] as Map<String, dynamic>? ?? {};
    
    final dailyPlans = plansData.map(
      (key, value) => MapEntry(key, DailyMealPlan.fromMap(value)),
    );

    return MealPlan(
      id: doc.id,
      startDate: data['startDate'] ?? Timestamp.now(),
      dailyPlans: dailyPlans,
    );
  }

  // Converte o objeto MealPlan para um mapa para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'dailyPlans': dailyPlans.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }
}
