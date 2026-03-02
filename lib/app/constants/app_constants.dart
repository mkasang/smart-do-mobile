class AppConstants {
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String listsCacheKey = 'cached_lists';
  static const String statsCacheKey = 'cached_stats';

  // Pagination
  static const int defaultPageSize = 10;

  // Debounce duration
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Cache duration
  static const Duration cacheValidity = Duration(hours: 1);
}
