import 'package:get/get.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/services/auth_service.dart';
import 'package:smart_do/services/cache_service.dart';
import 'package:smart_do/services/connectivity_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/theme/theme_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Services (singletons)
    Get.put(ApiService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(SnackbarService(), permanent: true);

    // Services asynchrones
    Get.putAsync<CacheService>(() async => await CacheService().init());
    Get.put(ConnectivityService(), permanent: true);

    // Controllers globaux
    Get.put(ThemeController(), permanent: true);
  }
}
