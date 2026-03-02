import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/app/bindings/initial_binding.dart';
import 'package:smart_do/app/routes/app_pages.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/app/theme/app_theme.dart';
import 'package:smart_do/services/snackbar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des services
  InitialBinding().dependencies();

  runApp(const SmartDoApp());
}

class SmartDoApp extends StatelessWidget {
  const SmartDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Do',
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),

      // Supprimer routingCallback qui cause l'erreur

      // Gestion globale des erreurs
      builder: (context, child) {
        ErrorWidget.builder = (errorDetails) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<SnackbarService>().showError(
              'Une erreur inattendue est survenue',
            );
          });
          return const SizedBox.shrink();
        };
        return child!;
      },
    );
  }
}
