// =================================================================
// 📁 ARQUIVO: lib/models/dri_model.dart
// =================================================================
// 🎯 Modelo de dados para encapsular as Metas de Ingestão Diária.

class DietaryReferenceIntake {
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  DietaryReferenceIntake({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });
}
