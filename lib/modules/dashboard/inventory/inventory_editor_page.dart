// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/inventory_editor_page.dart
// =================================================================
// 📝 Página para adicionar ou editar um item do estoque.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/inventory_item_model.dart';
import '../../../services/database_service.dart';

class InventoryEditorPage extends StatefulWidget {
  final InventoryItem? item;
  const InventoryEditorPage({super.key, this.item});

  @override
  State<InventoryEditorPage> createState() => _InventoryEditorPageState();
}

class _InventoryEditorPageState extends State<InventoryEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedUnit;
  final List<String> _units = ['g', 'kg', 'ml', 'L', 'unidade(s)'];
  late final DatabaseService _dbService;
  bool _isLoading = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _dbService = DatabaseService(uid: user?.uid);

    if (_isEditing) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _selectedUnit = widget.item!.unit;
    } else {
      _selectedUnit = _units.first;
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final item = InventoryItem(
        id: _isEditing ? widget.item!.id : 'new',
        name: _nameController.text.trim(),
        quantity: double.tryParse(_quantityController.text) ?? 0.0,
        unit: _selectedUnit!,
      );
      await _dbService.upsertInventoryItem(item); 
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // ... (tratamento de erro)
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    if (!_isEditing) return;
    // ... (lógica de confirmação e exclusão)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Item' : 'Adicionar Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Item')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _selectedUnit = v),
                  )),
                ],
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isEditing) TextButton(onPressed: _deleteItem, child: const Text('Excluir', style: TextStyle(color: Colors.red))),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _saveItem, child: const Text('Salvar')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
