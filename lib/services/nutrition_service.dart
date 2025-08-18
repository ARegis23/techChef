// =================================================================
// 📁 ARQUIVO: lib/services/nutrition_service.dart
// =================================================================
// 🧠 Serviço para realizar cálculos nutricionais, como o Gasto Energético Total.

//import 'dart:math';
import '../models/user_model.dart';
import '../models/family_member_model.dart';

class NutritionService {
  // Calcula a idade a partir da data de nascimento.
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Mapeia o nível de atividade para o seu coeficiente PAL, ajustado por idade.
  double _getActivityMultiplier(String? activityLevel, int age) {
    // Coeficientes PAL para adultos (21+)
    if (age >= 21) {
      switch (activityLevel) {
        case 'Sedentário': return 1.2;
        case 'Levemente Ativo': return 1.375;
        case 'Moderado': return 1.55;
        case 'Ativo': return 1.725;
        case 'Extremamente Ativo': return 1.9;
        default: return 1.2;
      }
    } else {
      // Coeficientes PAL para crianças e adolescentes (3-20), geralmente um pouco mais altos.
      switch (activityLevel) {
        case 'Sedentário': return 1.3;
        case 'Levemente Ativo': return 1.45;
        case 'Moderado': return 1.6;
        case 'Ativo': return 1.8;
        case 'Extremamente Ativo': return 2.0;
        default: return 1.3;
      }
    }
  }

  // Calcula o Gasto Energético Total (GET/TDEE) para um indivíduo.
  // Utiliza uma abordagem híbrida:
  // - Equações da OMS/FAO para crianças e adolescentes (3 a 20 anos).
  // - Equação de Mifflin-St Jeor para adultos (21 anos ou mais).
  double calculateTDEE({
    required double weight, // em kg
    required double height, // em cm
    required DateTime birthDate,
    required String gender, // 'Masculino' ou 'Feminino'
    required String activityLevel,
  }) {
    final age = _calculateAge(birthDate);

    // Exclui crianças com menos de 3 anos do cálculo.
    if (age < 3) {
      return 0.0;
    }

    double bmr; // Taxa Metabólica Basal (TMB)

    if (age >= 21) {
      // Para adultos (21+), usa a equação de Mifflin-St Jeor.
      if (gender == 'Masculino') {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      } else { // 'Feminino' ou 'Intersexo' (usa a fórmula feminina como base)
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      }
    } else {
      // Para crianças e adolescentes (3-20), usa as equações da OMS/FAO.
      if (gender == 'Masculino') {
        if (age < 10) { // 3 a 9 anos
          bmr = (22.7 * weight) + 495;
        } else if (age < 18) { // 10 a 17 anos
          bmr = (17.5 * weight) + 651;
        } else { // 18 a 20 anos
          bmr = (15.3 * weight) + 679;
        }
      } else { // 'Feminino' ou 'Intersexo'
        if (age < 10) { // 3 a 9 anos
          bmr = (22.5 * weight) + 499;
        } else if (age < 18) { // 10 a 17 anos
          bmr = (12.2 * weight) + 746;
        } else { // 18 a 20 anos
          bmr = (14.7 * weight) + 496;
        }
      }
    }

    final activityMultiplier = _getActivityMultiplier(activityLevel, age);
    
    // GET = TMB * Fator de Atividade
    return bmr * activityMultiplier;
  }

  // Calcula o GET total para toda a família.
  double calculateFamilyTDEE(AppUser admin, List<FamilyMember> family) {
    double totalTDEE = 0;

    // Calcula para o admin
    if (admin.weight != null && admin.height != null && admin.birthDate != null && admin.gender != null && admin.activityLevel != null) {
      totalTDEE += calculateTDEE(
        weight: admin.weight!,
        height: admin.height!,
        birthDate: admin.birthDate!.toDate(),
        gender: admin.gender!,
        activityLevel: admin.activityLevel!,
      );
    }

    // Soma o de cada familiar
    for (var member in family) {
      if (member.weight != null && member.height != null && member.birthDate != null && member.gender != null && member.activityLevel != null) {
        totalTDEE += calculateTDEE(
          weight: member.weight!,
          height: member.height!,
          birthDate: member.birthDate!.toDate(),
          gender: member.gender!,
          activityLevel: member.activityLevel!,
        );
      }
    }
    return totalTDEE;
  }
}
