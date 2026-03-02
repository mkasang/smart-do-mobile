import 'package:get/get.dart';
import 'package:smart_do/controllers/list_controller.dart';
import 'package:smart_do/controllers/share_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListController>(() => ListController());
    Get.lazyPut<ShareController>(() => ShareController());
  }
}
