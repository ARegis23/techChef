// =================================================================
// 📁 ARQUIVO: lib/core/app_routes.dart
// =================================================================
// 🎯 Centraliza as constantes com os nomes das rotas para evitar erros.

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String about = '/about';

  // Rotas de funcionalidades
  static const String userDashboard = '/user/dashboard';
  static const String menus = '/menus';
  static const String shoppingPage = '/shopping';
  static const String inventoryList = '/inventory/list'; 

  // Rotas de perfil
  static const String userEditor = '/user/editor';
  static const String userFamilyView = '/user/family';
  static const String verifyEmail = '/auth/verify-email';

  // Rotas de cardápios
  static const String recipeBook = '/menus/recipes';
  static const String recipeEditor = '/menus/recipes/editor';
  static const String mealPlanner = '/menus/planner';

  // Rotas de estoque e compras
  static const String shoppingList = '/shopping/list';
  static const String purchaseHistory = '/shopping/history'; 
  static const String inventoryEditor = '/inventory/editor'; 
  static const String inventoryItemDetails = '/inventory/item/details';
}
