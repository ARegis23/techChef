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
  final List<String> instructions; // 🔧 ALTERADO: De String para List<String>
  final String? imageUrl;
  final int servings;
  final List<Ingredient> ingredients;
  
  // =================================================================
  // ✨ CAMPOS ADICIONADOS
  // =================================================================
  final int prepTime;   // Tempo de preparo em minutos
  final int cookTime;   // Tempo de cozimento em minutos
  final bool isPublic;  // Indica se a receita é do usuário ou da API

  Recipe({
    required this.id,
    required this.name,
    required this.instructions,
    this.imageUrl,
    required this.servings,
    required this.ingredients,
    // Adicionado ao construtor
    this.prepTime = 0,
    this.cookTime = 0,
    this.isPublic = false,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Converte a lista de ingredientes
    var ingredientsFromDb = data['ingredients'] as List<dynamic>? ?? [];
    List<Ingredient> ingredientsList = ingredientsFromDb.map((i) => Ingredient.fromMap(i)).toList();

    // Converte a lista de instruções (garante compatibilidade com dados antigos)
    var instructionsData = data['instructions'];
    List<String> instructionsList;
    if (instructionsData is String) {
      // Se for uma string (formato antigo), converte para uma lista com um item
      instructionsList = [instructionsData];
    } else if (instructionsData is List) {
      // Se já for uma lista, converte os elementos para String
      instructionsList = List<String>.from(instructionsData);
    } else {
      instructionsList = [];
    }

    return Recipe(
      id: doc.id,
      name: data['name'] ?? '',
      instructions: instructionsList,
      imageUrl: data['imageUrl'],
      servings: (data['servings'] as num?)?.toInt() ?? 1,
      ingredients: ingredientsList,
      prepTime: (data['prepTime'] as num?)?.toInt() ?? 0,
      cookTime: (data['cookTime'] as num?)?.toInt() ?? 0,
      isPublic: data['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'servings': servings,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'prepTime': prepTime,
      'cookTime': cookTime,
      'isPublic': isPublic,
    };
  }
}
