// =================================================================
// 📁 ARQUIVO: lib/models/recipe_model.dart
// =================================================================
// 🍲 Modelo de dados para representar uma Receita e os seus Ingredientes.

import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String name;
  final double quantity;
  final String unit; // ex: 'g', 'kg', 'ml', 'L', 'unidade(s)'

  Ingredient({required this.name, required this.quantity, required this.unit});

  Map<String, dynamic> toMap() => {'name': name, 'quantity': quantity, 'unit': unit};

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final String instructions;
  final String? imageUrl;
  final int servings; // Para quantas pessoas a receita base serve
  final List<Ingredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.instructions,
    this.imageUrl,
    required this.servings,
    required this.ingredients,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var ingredientsFromDb = data['ingredients'] as List<dynamic>? ?? [];
    List<Ingredient> ingredientsList = ingredientsFromDb.map((i) => Ingredient.fromMap(i)).toList();

    return Recipe(
      id: doc.id,
      name: data['name'] ?? '',
      instructions: data['instructions'] ?? '',
      imageUrl: data['imageUrl'],
      servings: (data['servings'] as num?)?.toInt() ?? 1,
      ingredients: ingredientsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'servings': servings,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
    };
  }
}
