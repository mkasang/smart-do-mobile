import 'package:get/get.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/views/auth/login_screen.dart';
import 'package:smart_do/views/auth/register_screen.dart';
import 'package:smart_do/views/dashboard/dashboard_screen.dart';
import 'package:smart_do/views/lists/create_list_screen.dart';
import 'package:smart_do/views/lists/list_detail_screen.dart';
import 'package:smart_do/views/sharing/share_list_screen.dart';
import 'package:smart_do/views/calendar/calendar_screen.dart';
import 'package:smart_do/views/stats/stats_screen.dart';
import 'package:smart_do/views/profile/profile_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => DashboardScreen()),
    GetPage(name: AppRoutes.createList, page: () => CreateListScreen()),
    GetPage(name: AppRoutes.listDetail, page: () => ListDetailScreen()),
    GetPage(name: AppRoutes.shareList, page: () => ShareListScreen()),
    GetPage(name: AppRoutes.calendar, page: () => CalendarScreen()),
    GetPage(name: AppRoutes.stats, page: () => StatsScreen()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
  ];
}
