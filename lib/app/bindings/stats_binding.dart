import 'package:get/get.dart';
import 'package:smart_do/controllers/stats_controller.dart';

class StatsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatsController>(() => StatsController());
  }
}
