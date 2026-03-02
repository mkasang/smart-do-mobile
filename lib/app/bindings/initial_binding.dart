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
    // 1. D'abord SnackbarService (car il est utilisé par ApiService)
    Get.put(SnackbarService(), permanent: true);

    // 2. Ensuite ApiService (qui dépend de SnackbarService)
    Get.put(ApiService(), permanent: true);

    // 3. Puis AuthService (qui dépend de ApiService)
    Get.put(AuthService(), permanent: true);

    // 4. Services asynchrones
    Get.putAsync<CacheService>(() async => await CacheService().init());
    Get.put(ConnectivityService(), permanent: true);

    // 5. Controllers globaux
    Get.put(ThemeController(), permanent: true);
  }
}
