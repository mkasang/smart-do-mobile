import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Attendre que l'initialisation soit terminée
    if (!authService.isInitialized.value) {
      print('⏳ AuthService pas encore initialisé...');
      return null;
    }

    // Si l'utilisateur est connecté et essaie d'aller sur login/register
    if (authService.isLoggedIn) {
      if (route == AppRoutes.login || route == AppRoutes.register) {
        print('🔄 Utilisateur connecté, redirection vers dashboard');
        return const RouteSettings(name: AppRoutes.dashboard);
      }
    }
    // Si l'utilisateur n'est pas connecté et essaie d'aller ailleurs que login/register
    else {
      if (route != AppRoutes.login && route != AppRoutes.register) {
        print('🔒 Utilisateur non connecté, redirection vers login');
        return const RouteSettings(name: AppRoutes.login);
      }
    }

    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    print('📍 Navigation vers: ${page?.name}');
    return page;
  }
}
