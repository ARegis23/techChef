// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/purchase_history_page.dart
// =================================================================
// 📜 Página para exibir o histórico de compras.

import 'package:flutter/material.dart';

class PurchaseHistoryPage extends StatelessWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
      ),
      body: const Center(
        child: Text('O conteúdo do Histórico de Compras será exibido aqui'),
     ),
    );
  }
}