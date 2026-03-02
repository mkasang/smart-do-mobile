import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String capitalizeAll() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool isValidEmail() {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool isValidPassword() {
    return length >= 6 &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[0-9]'));
  }

  String toInitials() {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    final now = DateTime.now();
    return isSameDay(now);
  }

  bool isTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  String toFrenchString() {
    final now = DateTime.now();
    if (isToday()) return "Aujourd'hui";
    if (isTomorrow()) return "Demain";
    if (isYesterday()) return "Hier";

    final daysDifference = difference(now).inDays;
    if (daysDifference > 0 && daysDifference < 7) {
      return 'Dans $daysDifference jour${daysDifference > 1 ? 's' : ''}';
    }

    return DateFormat('dd/MM/yyyy').format(this);
  }
}

extension DurationExtension on Duration {
  String toShortString() {
    if (inDays > 0) {
      return '${inDays}j ${inHours % 24}h';
    }
    if (inHours > 0) {
      return '${inHours}h ${inMinutes % 60}min';
    }
    if (inMinutes > 0) {
      return '${inMinutes}min';
    }
    return '${inSeconds}s';
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isLightMode => theme.brightness == Brightness.light;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
