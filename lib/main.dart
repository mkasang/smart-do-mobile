import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_do/app/bindings/initial_binding.dart';
import 'package:smart_do/app/routes/app_pages.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/app/theme/app_theme.dart';
import 'package:smart_do/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

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
      debugShowCheckedModeBanner: true,
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),

      // Middleware pour l'authentification
      routingCallback: (routing) {
        final authService = Get.find<AuthService>();
        if (authService.isInitialized.value) {
          print('🔄 Route actuelle: ${routing?.current}');
        }
      },

      builder: (context, child) {
        return Obx(() {
          final authService = Get.find<AuthService>();

          // Afficher un écran de chargement pendant l'initialisation
          if (!authService.isInitialized.value) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        });
      },
    );
  }
}
