class AppConfig {
  static const String appName = 'Smart Do';
  static const String version = '1.0.0';

  // API Configuration
  static const String apiBaseUrl = 'http://localhost/smart-do/api';
  static const int apiTimeoutSeconds = 30;

  // Cache Configuration
  static const int cacheValidityHours = 1;
  static const int maxCacheSize = 50; // Nombre max d'items en cache

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Security
  static const bool enableSecurity = true;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  // Features
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = false;

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration debounceDuration = Duration(milliseconds: 500);
}

class Environment {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  static String current = development;

  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
  static bool get isProduction => current == production;

  static String get apiBaseUrl {
    switch (current) {
      case development:
        return 'http://localhost/smart-do/api';
      case staging:
        return 'https://staging.smart-do.com/api';
      case production:
        return 'https://api.smart-do.com/api';
      default:
        return 'http://localhost/smart-do/api';
    }
  }
}
