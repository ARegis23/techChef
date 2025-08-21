// =================================================================
// 📁 ARQUIVO: lib/models/dri_model.dart
// =================================================================
// 📦 Modelo para armazenar as Metas de Ingestão Diária (DRI).

class DietaryReferenceIntake {
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double totalSugarsGrams;
  final double addedSugarsGrams;
  final double saturatedFatsGrams;
  final double transFatsGrams;
  final double fiberGrams;
  final double sodiumMg;

  DietaryReferenceIntake({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.totalSugarsGrams,
    required this.addedSugarsGrams,
    required this.saturatedFatsGrams,
    required this.transFatsGrams,
    required this.fiberGrams,
    required this.sodiumMg,
  });
}
