class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String createList = '/create-list';
  static const String listDetail = '/list-detail';
  static const String shareList = '/share-list';
  static const String calendar = '/calendar';
  static const String stats = '/stats';
  static const String profile = '/profile';

  // Routes avec paramètres
  static String listDetailWithId(int id) => '$listDetail?id=$id';
  static String shareListWithId(int id) => '$shareList?id=$id';
}
