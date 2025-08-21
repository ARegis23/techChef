// =================================================================
// 📁 ARQUIVO: lib/modules/shopping/shopping_page.dart
// =================================================================
// 🛒 Página principal para gerir a lista de compras ativa.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/inventory_item_model.dart'; // Importe o modelo de inventário
import '../../../services/database_service.dart';
import '../../../services/open_food_facts_service.dart';
import '../../../models/shopping_list_model.dart';
import 'package:uuid/uuid.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingListPage> {
  late final DatabaseService _dbService;
  final OpenFoodFactsService _apiService = OpenFoodFactsService();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();
  String _selectedUnit = 'unidade(s)';
  final List<String> _units = ['unidade(s)', 'g', 'kg', 'ml', 'L'];
  bool _isLoading = false;

  // =================================================================
  // 🔧 VARIÁVEL ADICIONADA
  // =================================================================
  // Para guardar o produto completo retornado pela API.
  InventoryItem? _scannedProduct;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _dbService = DatabaseService(uid: user?.uid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
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
          // =================================================================
          // 🔧 LÓGICA ATUALIZADA
          // =================================================================
          // Guarda o produto inteiro, não apenas o nome.
          _scannedProduct = product;
          _nameController.text = product.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto "${product.name}" encontrado!'), backgroundColor: Colors.green),
        );
      } else {
        setState(() => _scannedProduct = null); // Limpa se não encontrar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto não encontrado.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      setState(() => _scannedProduct = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao procurar produto: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _addItemToList() {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e quantidade são obrigatórios.'), backgroundColor: Colors.orange),
      );
      return;
    }

    // =================================================================
    // 🔧 LÓGICA ATUALIZADA
    // =================================================================
    // Passa os dados nutricionais do _scannedProduct para o ShoppingListItem.
    final item = ShoppingListItem(
      id: const Uuid().v4(),
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      quantity: double.tryParse(_quantityController.text) ?? 1.0,
      unit: _selectedUnit,
      // Anexa as informações da API ao item da lista
      barcode: _scannedProduct?.barcode,
      calories_100g: _scannedProduct?.calories_100g,
      proteins_100g: _scannedProduct?.proteins_100g,
      carbs_100g: _scannedProduct?.carbs_100g,
      fats_100g: _scannedProduct?.fats_100g,
    );
    _dbService.upsertShoppingItem(item);
    _clearForm();
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _barcodeController.clear();
    setState(() {
      _selectedUnit = _units.first;
      _scannedProduct = null; // Limpa o produto escaneado também
    });
  }
  
  void _showFinalizeDialog(ShoppingList list) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Finalizar Compra'),
      content: const Text('A sua compra foi total ou parcial?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          Navigator.of(ctx).pop();
          _confirmStockUpdate(list, true);
        }, child: const Text('Parcial')),
        ElevatedButton(onPressed: () {
          Navigator.of(ctx).pop();
          _confirmStockUpdate(list, false);
        }, child: const Text('Total')),
      ],
    ));
  }

  void _confirmStockUpdate(ShoppingList list, bool isPartial) {
      showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Atualizar Estoque?'),
      content: const Text('Deseja adicionar os itens comprados ao seu estoque?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Não')),
        ElevatedButton(onPressed: () {
          _dbService.finalizeShopping(list, isPartial);
          Navigator.of(ctx).pop();
        }, child: const Text('Sim, Atualizar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    // O resto do seu Widget build continua igual...
    // Nenhuma mudança visual é necessária aqui.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/shopping_list_background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<ShoppingList?>(
              stream: _dbService.activeShoppingListStream,
              builder: (context, snapshot) {
                final list = snapshot.data;
                final items = list?.items ?? [];
                
                double totalCost = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
                double boughtCost = items.where((i) => i.isBought).fold(0, (sum, item) => sum + (item.price * item.quantity));

                return Column(
                  children: [
                    // --- Formulário de Adição ---
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                            ),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {}, // TODO: Lógica de sugestão
                                      icon: const Icon(Icons.auto_awesome),
                                      label: const Text('Importar Itens Sugeridos'),
                                    ),
                                    const SizedBox(height: 24),
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
                                    TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Produto')),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(child: TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Preço Unitário'), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 16),
                                        Expanded(child: TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 16),
                                        Expanded(child: DropdownButtonFormField<String>(
                                          value: _selectedUnit,
                                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                          onChanged: (v) => setState(() => _selectedUnit = v!),
                                        )),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    if (_isLoading)
                                      const CircularProgressIndicator()
                                    else
                                      ElevatedButton(onPressed: _addItemToList, child: const Text('Adicionar à Lista')),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    // --- Lista de Itens ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return CheckboxListTile(
                            title: Text(item.name),
                            subtitle: Text('${item.quantity} ${item.unit} @ R\$${item.price.toStringAsFixed(2)} cada'),
                            secondary: Text('R\$${(item.quantity * item.price).toStringAsFixed(2)}'),
                            value: item.isBought,
                            onChanged: (isBought) {
                              setState(() => item.isBought = isBought!);
                              _dbService.upsertShoppingItem(item);
                            },
                          );
                        },
                      ),
                    ),
                    // --- Rodapé Fixo ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Previsão de Custo:', style: Theme.of(context).textTheme.bodyLarge),
                              Text('R\$${totalCost.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Comprado:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('R\$${boughtCost.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: () {}, child: const Text('Salvar Edições')),
                              const SizedBox(width: 8),
                              ElevatedButton(onPressed: list != null && items.isNotEmpty ? () => _showFinalizeDialog(list) : null, child: const Text('Confirmar Compra')),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
