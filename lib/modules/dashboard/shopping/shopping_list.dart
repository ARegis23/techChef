// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/inventory_list_page.dart
// =================================================================
// 清单 Página para exibir a lista de itens em estoque.

import 'package:flutter/material.dart';

class InventoryListPage extends StatelessWidget {
  const InventoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Estoque'),
      ),
      body: const Center(
        child: Text('O conteúdo da Lista de Estoque será exibido aqui'),
        ),
    );
  }
}