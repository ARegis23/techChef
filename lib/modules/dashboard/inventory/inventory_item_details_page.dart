// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/inventory_item_details_page.dart
// =================================================================
// 🔎 Página para exibir os detalhes completos de um item do estoque.



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/routes.dart';
import '../../../models/inventory_item_model.dart';

class InventoryItemDetailsPage extends StatelessWidget {
  final InventoryItem item;
  const InventoryItemDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Item',
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.inventoryEditor,
                arguments: {'item': item},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INFORMAÇÕES PRINCIPAIS ---
            _buildMainInfoCard(context),
            const SizedBox(height: 24),

            // --- INFORMAÇÕES NUTRICIONAIS ---
            Text('Informação Nutricional (por 100g/ml)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildNutritionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Imagem do produto
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    image: item.imageUrl != null
                        ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: item.imageUrl == null ? const Icon(Icons.shopping_basket_outlined, size: 40) : null,
                ),
                const SizedBox(width: 16),
                // Nome e Quantidade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.price_change_outlined, 'Último Preço', '€ ${item.lastPrice?.toStringAsFixed(2) ?? 'N/A'}'),
            if (item.lastPurchaseDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text('Comprado em: ${DateFormat('dd/MM/yyyy').format(item.lastPurchaseDate!.toDate())}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.qr_code_2, 'Código de Barras', item.barcode ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.local_fire_department_outlined, 'Calorias', '${item.calories_100g?.toStringAsFixed(0) ?? 'N/A'} kcal'),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.egg_outlined, 'Proteínas', '${item.proteins_100g?.toStringAsFixed(1) ?? 'N/A'} g'),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.bakery_dining_outlined, 'Carboidratos', '${item.carbs_100g?.toStringAsFixed(1) ?? 'N/A'} g'),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.water_drop_outlined, 'Gorduras', '${item.fats_100g?.toStringAsFixed(1) ?? 'N/A'} g'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 16),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(value),
      ],
    );
  }
}
