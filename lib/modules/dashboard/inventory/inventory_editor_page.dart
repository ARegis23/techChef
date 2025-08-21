// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/inventory_editor_page.dart
// =================================================================
// 📝 Página para adicionar ou editar um item do estoque, com integração da API.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/inventory_item_model.dart';
import '../../../services/database_service.dart';
import '../../../services/open_food_facts_service.dart';

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
  final _barcodeController = TextEditingController();
  String? _selectedUnit;
  final List<String> _units = ['unidade(s)', 'g', 'kg', 'ml', 'L'];
  late final DatabaseService _dbService;
  final OpenFoodFactsService _apiService = OpenFoodFactsService();
  bool _isLoading = false;
  InventoryItem? _scannedProduct; // Guarda os dados do produto encontrado

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
      _barcodeController.text = widget.item!.barcode ?? '';
    } else {
      _selectedUnit = _units.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _searchByBarcode() async {
    if (_barcodeController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final product = await _apiService.getProductByBarcode(_barcodeController.text.trim());
      if (product != null) {
        setState(() {
          _scannedProduct = product;
          _nameController.text = product.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto "${product.name}" encontrado!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto não encontrado.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao procurar produto: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // CORREÇÃO: Cria o item final combinando os dados do formulário com os da API.
      final item = InventoryItem(
        id: _isEditing ? widget.item!.id : 'new',
        name: _nameController.text.trim(),
        quantity: double.tryParse(_quantityController.text) ?? 0.0,
        unit: _selectedUnit!,
        // Se um produto foi escaneado, usa os dados dele. Senão, mantém os dados existentes (se estiver a editar).
        barcode: _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim() : (_isEditing ? widget.item?.barcode : null),
        imageUrl: _scannedProduct?.imageUrl ?? (_isEditing ? widget.item?.imageUrl : null),
        calories_100g: _scannedProduct?.calories_100g ?? (_isEditing ? widget.item?.calories_100g : null),
        proteins_100g: _scannedProduct?.proteins_100g ?? (_isEditing ? widget.item?.proteins_100g : null),
        carbs_100g: _scannedProduct?.carbs_100g ?? (_isEditing ? widget.item?.carbs_100g : null),
        fats_100g: _scannedProduct?.fats_100g ?? (_isEditing ? widget.item?.fats_100g : null),
        // Preserva os dados da última compra ao editar
        lastPrice: _isEditing ? widget.item?.lastPrice : null,
        lastPurchaseDate: _isEditing ? widget.item?.lastPurchaseDate : null,
      );

      await _dbService.upsertInventoryItem(item);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o item: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    if (!_isEditing) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem a certeza que deseja excluir este item do estoque?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.deleteInventoryItem(widget.item!.id);
      if (mounted) Navigator.of(context).pop();
    }
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
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Código de Barras (opcional)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchByBarcode,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Item'),
                validator: (v) => (v == null || v.isEmpty) ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  )),
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
