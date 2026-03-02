import 'package:get/get.dart';
import 'package:smart_do/controllers/share_controller.dart';

class ShareBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShareController>(() => ShareController());
  }
}
