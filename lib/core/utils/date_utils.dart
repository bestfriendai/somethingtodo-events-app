import 'package:intl/intl.dart';

/// Date utility functions
class DateTimeUtils {
  DateTimeUtils._();

  /// Format date to short format (MMM d)
  static String formatShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Format date to long format (MMMM d, yyyy)
  static String formatLong(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Format time (h:mm a)
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date and time (MMM d, yyyy • h:mm a)
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  /// Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      // Past dates
      if (difference.inDays.abs() >= 365) {
        final years = (difference.inDays.abs() / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays.abs() >= 30) {
        final months = (difference.inDays.abs() / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays.abs() >= 7) {
        final weeks = (difference.inDays.abs() / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (difference.inDays.abs() >= 1) {
        final days = difference.inDays.abs();
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours.abs() >= 1) {
        final hours = difference.inHours.abs();
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes.abs() >= 1) {
        final minutes = difference.inMinutes.abs();
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } else {
      // Future dates
      if (difference.inDays >= 365) {
        final years = (difference.inDays / 365).floor();
        return 'in $years ${years == 1 ? 'year' : 'years'}';
      } else if (difference.inDays >= 30) {
        final months = (difference.inDays / 30).floor();
        return 'in $months ${months == 1 ? 'month' : 'months'}';
      } else if (difference.inDays >= 7) {
        final weeks = (difference.inDays / 7).floor();
        return 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}';
      } else if (difference.inDays >= 1) {
        final days = difference.inDays;
        return 'in $days ${days == 1 ? 'day' : 'days'}';
      } else if (difference.inHours >= 1) {
        final hours = difference.inHours;
        return 'in $hours ${hours == 1 ? 'hour' : 'hours'}';
      } else if (difference.inMinutes >= 1) {
        final minutes = difference.inMinutes;
        return 'in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      } else {
        return 'Soon';
      }
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get day of week name
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Get formatted date range
  static String getDateRange(DateTime start, DateTime end) {
    if (start.year == end.year) {
      if (start.month == end.month) {
        if (start.day == end.day) {
          return formatLong(start);
        }
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
      }
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }
    return '${formatLong(start)} - ${formatLong(end)}';
  }

  /// Get age from date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
