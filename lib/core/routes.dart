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

    // Rotas de perfil
  static const String userDashboard = '/user/dashboard';
  static const String userEditor = '/user/editor';
  static const String userFamilyView = '/user/family';
  static const String verifyEmail = '/auth/verify-email';

  // Rotas de funcionalidades
  static const String menus = '/menus';
  static const String shoppingList = '/shopping';
  static const String inventory = '/inventory';

  //Rotas de Estoque.
  static const String inventoryList = '/inventory/list';
  static const String purchaseHistory = '/purchase/history';
}
