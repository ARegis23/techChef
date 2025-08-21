// =================================================================
// 📁 ARQUIVO: lib/core/route_generator.dart
// =================================================================
// 🚦 Controla a criação de todas as rotas do aplicativo.

import 'package:flutter/material.dart';
import '../modules/dashboard/inventory/inventory_editor_page.dart';
import '../modules/dashboard/inventory/inventory_item_details_page.dart';
import '../modules/dashboard/inventory/inventory_list_page.dart';
import '../modules/dashboard/menus/menu_dashboard.dart';
import '../modules/dashboard/menus/recipe_book_page.dart';
import '../modules/dashboard/menus/recipe_editor_page.dart';
import '../modules/dashboard/shopping/purchase_history.dart';
import '../modules/dashboard/shopping/shopping_dashboard.dart';
import '../modules/dashboard/shopping/shopping_list.dart';
import '../modules/dashboard/user/user_dashboard.dart';
import '../modules/dashboard/user/user_editor.dart';
import '../modules/dashboard/user/user_family_view.dart';
import 'routes.dart';
import '../models/recipe_model.dart';
import '../models/inventory_item_model.dart';

// Importação de todas as páginas
import '../modules/about/about.dart';
import '../modules/auth/login.dart';
import '../modules/auth/verify_email_page.dart';
import '../modules/dashboard/dashboard.dart';
import '../modules/settings/settings.dart';
import '../modules/splash/splash_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.splash) {
      return MaterialPageRoute(builder: (_) => const SplashPage());
    }

    return MaterialPageRoute(
      builder: (context) => FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 300)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return _buildPage(settings);
        },
      ),
      settings: settings,
    );
  }

  static Widget _buildPage(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      // Auth & Core
      case AppRoutes.login: return const LoginPage();
      case AppRoutes.verifyEmail: return const VerifyEmailPage();
      case AppRoutes.dashboard: return const DashboardPage();
      case AppRoutes.settings: return const SettingsPage();
      case AppRoutes.about: return const AboutPage();

      // Perfis
      case AppRoutes.userDashboard: return const UserDashboardPage();
      case AppRoutes.userEditor: return UserEditorPage(arguments: args);
      case AppRoutes.userFamilyView: return const UserFamilyViewPage();

      // Cardápios
      case AppRoutes.menus: return const MenusPage();
      case AppRoutes.recipeBook: return const RecipeBookPage();
      case AppRoutes.recipeEditor:
        final recipeToEdit = args?['recipe'] as Recipe?;
        return RecipeEditorPage(recipe: recipeToEdit);

      // Compras e Estoque
      case AppRoutes.shoppingPage: return const ShoppingPage();
      case AppRoutes.shoppingListPage: return const ShoppingListPage();
      case AppRoutes.inventoryList: return const InventoryListPage();
      case AppRoutes.purchaseHistory: return const PurchaseHistoryPage();
      case AppRoutes.inventoryEditor:
        final itemToEdit = args?['item'] as InventoryItem?;
        return InventoryEditorPage(item: itemToEdit);
      
      // CORREÇÃO: Leitura segura dos argumentos para evitar o TypeError 
      case AppRoutes.inventoryItemDetails:
        final item = args?['item'];
        if (item is InventoryItem) {
          return InventoryItemDetailsPage(item: item);
        }
        return _errorPage('Dados do item em falta ou inválidos.');

      // Rota de Erro
      default:
        return _errorPage('Rota não encontrada para "${settings.name}"');
    }
  }

  // Widget de erro genérico
  static Widget _errorPage(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro de Rota')),
      body: Center(child: Text('ERRO: $message')),
    );
  }
}
