import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static final DateFormat _shortDate = DateFormat('d MMM', 'tr_TR');
  static final DateFormat _fullDate = DateFormat('d MMMM yyyy', 'tr_TR');
  static final DateFormat _fallbackDate = DateFormat('dd.MM.yyyy');

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return _shortDate.format(date.toLocal());
    } catch (_) {
      return _fallbackDate.format(date.toLocal());
    }
  }

  static String formatFullDate(DateTime? date) {
    if (date == null) return '';
    try {
      return _fullDate.format(date.toLocal());
    } catch (_) {
      return _fallbackDate.format(date.toLocal());
    }
  }

  static bool isOverdue(DateTime? dueDate, {required bool isDone}) {
    if (isDone || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }
}
