import 'package:get/get.dart';
import 'package:smart_do/app/bindings/auth_binding.dart';
import 'package:smart_do/app/bindings/calendar_binding.dart';
import 'package:smart_do/app/bindings/dashboard_binding.dart';
import 'package:smart_do/app/bindings/list_detail_binding.dart';
import 'package:smart_do/app/bindings/profile_binding.dart';
import 'package:smart_do/app/bindings/share_binding.dart';
import 'package:smart_do/app/bindings/stats_binding.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/views/auth/login_screen.dart';
import 'package:smart_do/views/auth/register_screen.dart';
import 'package:smart_do/views/calendar/calendar_screen.dart';
import 'package:smart_do/views/dashboard/dashboard_screen.dart';
import 'package:smart_do/views/lists/create_list_screen.dart';
import 'package:smart_do/views/lists/list_detail_screen.dart';
import 'package:smart_do/views/profile/profile_screen.dart';
import 'package:smart_do/views/sharing/share_list_screen.dart';
import 'package:smart_do/views/stats/stats_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.createList,
      page: () => CreateListScreen(),
      binding: DashboardBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.listDetail,
      page: () => ListDetailScreen(),
      binding: ListDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.shareList,
      page: () => ShareListScreen(),
      binding: ShareBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => CalendarScreen(),
      binding: CalendarBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.stats,
      page: () => StatsScreen(),
      binding: StatsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
