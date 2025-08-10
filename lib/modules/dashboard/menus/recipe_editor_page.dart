// =================================================================
// 📁 ARQUIVO: lib/modules/menus/recipe_editor_page.dart
// =================================================================
// 📝 Página final e completa para gestão de receitas, com todas as funcionalidades.

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/recipe_model.dart';
import '../../../services/database_service.dart';
import '../../../services/storage_service.dart';

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
  final _instructionsController = TextEditingController();
  late final DatabaseService _dbService;
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  XFile? _selectedImageFile;
  String? _existingImageUrl;

  final List<Map<String, dynamic>> _ingredientsData = [];
  final List<String> _units = ['g', 'kg', 'ml', 'L', 'unidade(s)', 'xícara(s)', 'colher(es) de sopa'];

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
      _instructionsController.text = recipe.instructions;
      _existingImageUrl = recipe.imageUrl;
      for (var ingredient in recipe.ingredients) {
        _addIngredientField(ingredient: ingredient);
      }
    } else {
      _addIngredientField();
    }
  }

  void _addIngredientField({Ingredient? ingredient}) {
    setState(() {
      _ingredientsData.add({
        'nameController': TextEditingController(text: ingredient?.name),
        'quantityController': TextEditingController(text: ingredient?.quantity.toString()),
        'unit': ingredient?.unit ?? _units.first,
      });
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      (_ingredientsData[index]['nameController'] as TextEditingController).dispose();
      (_ingredientsData[index]['quantityController'] as TextEditingController).dispose();
      _ingredientsData.removeAt(index);
    });
  }
  
  Future<void> _pickImage() async {
    final image = await _storageService.pickImage();
    if (image != null) {
      setState(() => _selectedImageFile = image);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    String? finalImageUrl = _existingImageUrl;

    try {
      if (_isEditing && widget.recipe!.imageUrl != null && _existingImageUrl == null && _selectedImageFile == null) {
        await _storageService.deleteImageByUrl(widget.recipe!.imageUrl!);
      }

      if (_selectedImageFile != null && currentUser != null) {
        final recipeId = _isEditing ? widget.recipe!.id : 'recipe_${DateTime.now().millisecondsSinceEpoch}';
        finalImageUrl = await _storageService.uploadProfilePicture(
          adminId: currentUser.uid,
          profileId: recipeId,
          file: _selectedImageFile!,
        );
      }

      final ingredients = _ingredientsData.map((data) {
        return Ingredient(
          name: (data['nameController'] as TextEditingController).text.trim(),
          quantity: double.tryParse((data['quantityController'] as TextEditingController).text) ?? 0.0,
          unit: data['unit'],
        );
      }).toList();

      final recipe = Recipe(
        id: _isEditing ? widget.recipe!.id : 'new',
        name: _nameController.text.trim(),
        servings: int.tryParse(_servingsController.text) ?? 1,
        instructions: _instructionsController.text.trim(),
        ingredients: ingredients,
        imageUrl: finalImageUrl,
      );

      await _dbService.upsertRecipe(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita salva com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar a receita: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecipe() async {
    if (!_isEditing) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem a certeza que deseja excluir esta receita?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        if(widget.recipe!.imageUrl != null) {
          await _storageService.deleteImageByUrl(widget.recipe!.imageUrl!);
        }
        await _dbService.deleteRecipe(widget.recipe!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receita excluída com sucesso!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir a receita: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    _instructionsController.dispose();
    for (var data in _ingredientsData) {
      (data['nameController'] as TextEditingController).dispose();
      (data['quantityController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage = _selectedImageFile != null || _existingImageUrl != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Receita' : 'Nova Receita'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('perfil_build.jpg'), // Imagem de fundo
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informações da Receita', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome da Receita'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                            const SizedBox(height: 16),
                            TextFormField(controller: _servingsController, decoration: const InputDecoration(labelText: 'Serve (Nº de Pessoas)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                            const SizedBox(height: 16),
                            TextFormField(controller: _instructionsController, decoration: const InputDecoration(labelText: 'Modo de Preparo', alignLabelWithHint: true), maxLines: 8, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                            
                            const Divider(height: 40),
                            Text('Ingredientes', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _ingredientsData.length,
                              itemBuilder: (context, index) {
                                return _buildIngredientTile(index);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar Ingrediente'),
                              onPressed: _addIngredientField,
                            ),

                            const Divider(height: 40),
                            Text('Foto do Prato', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: _selectedImageFile != null
                                              ? (kIsWeb ? NetworkImage(_selectedImageFile!.path) : FileImage(File(_selectedImageFile!.path))) as ImageProvider
                                              : (_existingImageUrl != null ? NetworkImage(_existingImageUrl!) : const AssetImage('placeholder.png')),
                                        ),
                                      ),
                                      child: !hasImage
                                          ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.white))
                                          : null,
                                    ),
                                  ),
                                ),
                                if (hasImage)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black.withOpacity(0.6),
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        onPressed: _removeImage,
                                        tooltip: 'Remover Imagem',
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 32),
                            if (_isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_isEditing)
                                    TextButton(
                                      onPressed: _deleteRecipe,
                                      child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                    ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancelar'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _saveRecipe,
                                    child: const Text('Salvar'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientTile(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _ingredientsData[index]['nameController'],
                decoration: const InputDecoration(labelText: 'Ingrediente'),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _ingredientsData[index]['quantityController'],
                decoration: const InputDecoration(labelText: 'Qtd.'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _ingredientsData[index]['unit'],
                items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (value) {
                  setState(() {
                    _ingredientsData[index]['unit'] = value!;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeIngredientField(index),
            ),
          ],
        ),
      ),
    );
  }
}
