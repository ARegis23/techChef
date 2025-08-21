// =================================================================
// 📁 ARQUIVO: lib/modules/inventory/purchase_history_page.dart
// =================================================================
// 📜 Página para exibir o histórico de compras.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/shopping_list_model.dart';
import '../../../services/database_service.dart';
//import 'package:intl/intl.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
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
        title: const Text('Histórico de Compras'),
      ),
      body: StreamBuilder<List<ShoppingList>>(
        stream: _dbService.shoppingHistoryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma compra registada no histórico.'));
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final list = history[index];
              final totalCost = list.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(list.name),
                  subtitle: Text('€${totalCost.toStringAsFixed(2)}'),
                  children: list.items.map((item) => ListTile(
                    title: Text(item.name),
                    trailing: Text('${item.quantity} ${item.unit}'),
                  )).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
