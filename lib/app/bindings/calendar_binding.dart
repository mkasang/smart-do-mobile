import 'package:get/get.dart';
import 'package:smart_do/controllers/calendar_controller.dart';

class CalendarBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarController>(() => CalendarController());
  }
}
