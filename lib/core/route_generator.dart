// =================================================================
// 📁 ARQUIVO: lib/core/route_generator.dart
// =================================================================
// 🚦 Controla a criação de todas as rotas.

import 'package:flutter/material.dart';
import 'routes.dart';
import '../modules/about/about.dart';
import '../modules/auth/login.dart';
import '../modules/auth/verify_email_page.dart';
import '../modules/dashboard/dashboard.dart';
import '../modules/settings/settings.dart';
import '../modules/splash/splash_page.dart';
import '../modules/dashboard/user/user_dashboard.dart';
import '../modules/dashboard/user/user_editor.dart';
import '../modules/dashboard/user/user_family_view.dart';
import '../modules/dashboard/menus/menu_dashboard.dart';
import '../modules/dashboard/shopping/shopping_dashboard.dart';
import '../modules/dashboard/inventory/inventory_dashboard.dart';
import '../modules/dashboard/inventory/inventory_list.dart';
import '../modules/dashboard/inventory/purchase_history.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('✅ [RouteGenerator] ROTA CHAMADA: ${settings.name}');

    final args = settings.arguments as Map<String, dynamic>?;

    Widget page;
    switch (settings.name) {
      case AppRoutes.splash:
        page = const SplashPage();
        break;
      case AppRoutes.login:
        page = const LoginPage();
        break;
      case AppRoutes.dashboard:
        page = const DashboardPage();
        break;
      case AppRoutes.settings:
        page = const SettingsPage();
        break;
      case AppRoutes.about:
        page = const AboutPage();
        break;
      case AppRoutes.userDashboard:
        page = const UserDashboardPage();
        break;
      case AppRoutes.userEditor:
        page = UserEditorPage(arguments: args);
        break;
      case AppRoutes.userFamilyView:
        page = const UserFamilyViewPage();
        break;
      case AppRoutes.menus:
        page = const MenusPage();
        break;
      case AppRoutes.shoppingList:
        page = const ShoppingPage();
        break;
      case AppRoutes.inventory:
        page = const InventoryPage();
        break;  
        case AppRoutes.inventoryList:
        page = const InventoryListPage();
        break;
      case AppRoutes.purchaseHistory:
        page = const PurchaseHistoryPage();
        break;
      
      // 2. ADICIONE O CASO PARA A NOVA ROTA
      case AppRoutes.verifyEmail:
        page = const VerifyEmailPage();
        break;

      default:
        page = Scaffold(
          appBar: AppBar(title: const Text('Erro de Rota')),
          body: Center(child: Text('ERRO: Rota não encontrada para "${settings.name}"')),
        );
        break;
    }
    
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
