// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/inventory_list_page.dart
// =================================================================
// Página principal para visualizar e gerir o estoque em tempo real.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/routes.dart';
import '../../../models/inventory_item_model.dart';
import '../../../services/database_service.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  late final DatabaseService _dbService;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _dbService = DatabaseService(uid: user?.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Estoque'),
      ),
      body: StreamBuilder<List<InventoryItem>>(
        stream: _dbService.inventoryStream, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar o estoque.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('O seu estoque está vazio.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Importar da Última Compra'),
                    onPressed: () {
                      // TODO: Implementar a lógica para buscar a última lista de compras
                      // e popular o estoque com os itens dela.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidade em breve!')),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          final inventoryItems = snapshot.data!;
          return ListView.builder(
            itemCount: inventoryItems.length,
            itemBuilder: (context, index) {
              final item = inventoryItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(item.name),
                  trailing: Text('${item.quantity} ${item.unit}'),
                  onTap: () {
                    // NAVEGA PARA A NOVA TELA DE DETALHES
                    Navigator.of(context).pushNamed(
                      AppRoutes.inventoryItemDetails,
                      arguments: {'item': item},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de edição em modo de "adicionar novo item"
          Navigator.of(context).pushNamed(AppRoutes.inventoryEditor);
        },
        tooltip: 'Adicionar Item Manualmente',
        child: const Icon(Icons.add),
      ),
    );
  }
}
