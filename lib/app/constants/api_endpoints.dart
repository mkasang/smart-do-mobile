class ApiEndpoints {
  static const String baseUrl = 'https://smart-do.jobyrdc.com/api';

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String profile = '/profile';

  // Lists
  static const String lists = '/lists';
  static String listDetail(int id) => '/lists/$id';
  static String duplicateList(int id) => '/lists/$id/duplicate';

  // Items
  static const String items = '/items';
  static String toggleItem(int id) => '/items/$id/toggle';

  // Sharing
  static const String userSearch = '/users/search';
  static String shareList(int id) => '/lists/$id/share';
  static const String sharedLists = '/lists/shared';
  static String removeShare(int listId, int userId) =>
      '/lists/$listId/share/$userId';

  // Calendar & Stats
  static const String calendar = '/calendar';
  static const String stats = '/stats';
}
