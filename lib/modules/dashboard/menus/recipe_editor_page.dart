// =================================================================
// 📁 ARQUIVO: lib/modules/dashboard/menus/recipe_editor_page.dart
// =================================================================
// 📝 Página para criar ou editar uma receita.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/recipe_model.dart';
import '../../../../services/database_service.dart';

// Classe auxiliar para gerenciar os controllers de cada ingrediente
class IngredientController {
  final TextEditingController name;
  final TextEditingController quantity;
  String unit;

  IngredientController({required this.name, required this.quantity, required this.unit});

  void dispose() {
    name.dispose();
    quantity.dispose();
  }
}

class RecipeEditorPage extends StatefulWidget {
  final Recipe? recipe;
  const RecipeEditorPage({super.key, this.recipe});

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingsController = TextEditingController();
  String? _existingImageUrl;
  
  // Listas de controllers para os campos dinâmicos
  final List<TextEditingController> _instructionControllers = [];
  final List<IngredientController> _ingredientControllers = [];
  final List<String> _unitOptions = ['unidade(s)', 'g', 'kg', 'ml', 'L', 'xícara(s)', 'colher(es) de sopa'];

  late final DatabaseService _dbService;
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _dbService = DatabaseService(uid: user?.uid);

    if (_isEditing) {
      final recipe = widget.recipe!;
      _nameController.text = recipe.name;
      _servingsController.text = recipe.servings.toString();
      _existingImageUrl = recipe.imageUrl;
      
      _setupInstructionControllers(recipe.instructions);
      _setupIngredientControllers(recipe.ingredients);
    } else {
      _addInstructionField();
      _addIngredientField();
    }
  }

  void _setupInstructionControllers(List<String> instructions) {
    _instructionControllers.clear();
    if (instructions.isEmpty) {
      _addInstructionField();
    } else {
      for (var instruction in instructions) {
        _addInstructionField(text: instruction);
      }
    }
  }

  void _setupIngredientControllers(List<Ingredient> ingredients) {
    _ingredientControllers.clear();
    if (ingredients.isEmpty) {
      _addIngredientField();
    } else {
      for (var ingredient in ingredients) {
        _addIngredientField(ingredient: ingredient);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addInstructionField({String text = ''}) {
    setState(() {
      _instructionControllers.add(TextEditingController(text: text));
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  void _addIngredientField({Ingredient? ingredient}) {
    setState(() {
      _ingredientControllers.add(IngredientController(
        name: TextEditingController(text: ingredient?.name ?? ''),
        quantity: TextEditingController(text: ingredient?.quantity.toString() ?? '0'),
        unit: ingredient?.unit ?? _unitOptions.first,
      ));
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final instructionsList = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final ingredientsList = _ingredientControllers
        .map((controllers) => Ingredient(
              name: controllers.name.text.trim(),
              quantity: double.tryParse(controllers.quantity.text) ?? 0.0,
              unit: controllers.unit,
            ))
        .where((i) => i.name.isNotEmpty && i.quantity > 0)
        .toList();

    final recipe = Recipe(
      id: _isEditing ? widget.recipe!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      servings: int.tryParse(_servingsController.text) ?? 1,
      instructions: instructionsList,
      ingredients: ingredientsList,
      imageUrl: _existingImageUrl,
      prepTime: _isEditing ? widget.recipe!.prepTime : 0,
      cookTime: _isEditing ? widget.recipe!.cookTime : 0,
      isPublic: _isEditing ? widget.recipe!.isPublic : false,
    );

    await _dbService.upsertRecipe(recipe);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Receita' : 'Nova Receita'),
        actions: [
          IconButton(onPressed: _saveRecipe, icon: const Icon(Icons.save_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Receita'),
                validator: (v) => v!.isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Serve (pessoas)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              
              Text('Ingredientes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._buildIngredientFields(),
              TextButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Ingrediente'),
              ),
              const SizedBox(height: 24),

              Text('Instruções', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._buildInstructionFields(),
              TextButton.icon(
                onPressed: _addInstructionField,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Passo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIngredientFields() {
    return List.generate(_ingredientControllers.length, (index) {
      final controllers = _ingredientControllers[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: controllers.name,
                decoration: const InputDecoration(labelText: 'Ingrediente'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: controllers.quantity,
                decoration: const InputDecoration(labelText: 'Qtd.'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: controllers.unit,
                items: _unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) => setState(() => controllers.unit = v!),
              ),
            ),
            if (_ingredientControllers.length > 1)
              IconButton(
                onPressed: () => _removeIngredientField(index),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildInstructionFields() {
    return List.generate(_instructionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Text('${index + 1}.', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _instructionControllers[index],
                decoration: const InputDecoration(labelText: 'Passo'),
                maxLines: null,
              ),
            ),
            if (_instructionControllers.length > 1)
              IconButton(
                onPressed: () => _removeInstructionField(index),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
          ],
        ),
      );
    });
  }
}
