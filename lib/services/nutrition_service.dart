// =================================================================
// 📁 ARQUIVO: lib/services/nutrition_service.dart
// =================================================================
// 🧪 Serviço para realizar cálculos nutricionais.

import 'dart:math';
import '../models/dri_model.dart';

class NutritionService {

  DietaryReferenceIntake calculateDRIs({
    required double weight,
    required double height,
    required DateTime birthDate,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    final age = DateTime.now().difference(birthDate).inDays / 365.25;

    // Equação de Harris-Benedict para Taxa Metabólica Basal (TMB)
    double bmr;
    if (gender == 'Masculino') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else { // 'Feminino'
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // Multiplicador de Nível de Atividade
    double activityMultiplier;
    switch (activityLevel) {
      case 'Sedentário': activityMultiplier = 1.2; break;
      case 'Leve': activityMultiplier = 1.375; break;
      case 'Moderado': activityMultiplier = 1.55; break;
      case 'Ativo': activityMultiplier = 1.725; break;
      case 'Muito Ativo': activityMultiplier = 1.9; break;
      default: activityMultiplier = 1.2;
    }

    // Gasto Energético Total Diário (GET)
    double tdee = bmr * activityMultiplier;

    // Ajuste de calorias com base no objetivo
    double finalCalories;
    switch (goal) {
      case 'Perder Peso': finalCalories = tdee - 500; break;
      case 'Manter Peso': finalCalories = tdee; break;
      case 'Aumentar Peso': finalCalories = tdee + 500; break;
      default: finalCalories = tdee;
    }

    // Cálculo de Macronutrientes (Ex: 40% Carb, 30% Prot, 30% Gord)
    final carbsGrams = (finalCalories * 0.40) / 4;
    final proteinGrams = (finalCalories * 0.30) / 4;
    final fatGrams = (finalCalories * 0.30) / 9;

    // Cálculo de outros nutrientes com base em diretrizes
    final addedSugarsGrams = (finalCalories * 0.10) / 4; // Máx 10% das calorias
    final saturatedFatsGrams = (finalCalories * 0.10) / 9; // Máx 10% das calorias
    final fiberGrams = (finalCalories / 1000) * 14; // Recomendação: 14g por 1000 kcal
    
    return DietaryReferenceIntake(
      calories: finalCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      totalSugarsGrams: max(0, carbsGrams - fiberGrams), // Estimativa simples
      addedSugarsGrams: addedSugarsGrams,
      saturatedFatsGrams: saturatedFatsGrams,
      transFatsGrams: 0.0, // Meta é sempre zero
      fiberGrams: fiberGrams,
      sodiumMg: 2300.0, // Limite geral recomendado
    );
  }
}
