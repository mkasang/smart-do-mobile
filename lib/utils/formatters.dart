import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'fr_FR');

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  static String formatTime(String? time) {
    if (time == null) return '';
    return time.substring(0, 5);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  static String formatMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);

    if (due == today) return "Aujourd'hui";
    if (due == today.add(const Duration(days: 1))) return "Demain";
    if (due == today.subtract(const Duration(days: 1))) return "Hier";

    final difference = due.difference(today).inDays;
    if (difference > 0 && difference < 7) {
      return 'Dans $difference jour${difference > 1 ? 's' : ''}';
    }
    if (difference < 0 && difference > -7) {
      return 'Il y a ${-difference} jour${-difference > 1 ? 's' : ''}';
    }

    return formatDate(date);
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}j ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    }
    return '${duration.inSeconds}s';
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
