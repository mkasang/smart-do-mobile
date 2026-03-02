import 'package:get/get.dart';
import 'package:smart_do/controllers/item_controller.dart';

class ListDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemController>(() => ItemController());
    // ListController est déjà disponible via DashboardBinding
  }
}
