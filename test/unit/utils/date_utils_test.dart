import 'package:flutter_test/flutter_test.dart';
import 'package:somethingtodo/core/utils/date_utils.dart';

void main() {
  group('DateTimeUtils', () {
    final testDate = DateTime(2024, 3, 15, 14, 30, 0); // March 15, 2024, 2:30 PM

    group('formatShort', () {
      test('should format date to short format', () {
        expect(DateTimeUtils.formatShort(testDate), equals('Mar 15'));
      });
    });

    group('formatLong', () {
      test('should format date to long format', () {
        expect(DateTimeUtils.formatLong(testDate), equals('March 15, 2024'));
      });
    });

    group('formatTime', () {
      test('should format time correctly', () {
        expect(DateTimeUtils.formatTime(testDate), equals('2:30 PM'));
        
        final morningTime = DateTime(2024, 3, 15, 9, 5, 0);
        expect(DateTimeUtils.formatTime(morningTime), equals('9:05 AM'));
      });
    });

    group('formatDateTime', () {
      test('should format date and time together', () {
        expect(DateTimeUtils.formatDateTime(testDate), equals('Mar 15, 2024 • 2:30 PM'));
      });
    });

    group('getRelativeTime', () {
      test('should return "Just now" for current time', () {
        final now = DateTime.now();
        expect(DateTimeUtils.getRelativeTime(now), equals('Just now'));
      });

      test('should return minutes ago', () {
        final thirtyMinutesAgo = DateTime.now().subtract(Duration(minutes: 30));
        expect(DateTimeUtils.getRelativeTime(thirtyMinutesAgo), equals('30 minutes ago'));
      });

      test('should return hours ago', () {
        final twoHoursAgo = DateTime.now().subtract(Duration(hours: 2));
        expect(DateTimeUtils.getRelativeTime(twoHoursAgo), equals('2 hours ago'));
      });

      test('should return days ago', () {
        final threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
        expect(DateTimeUtils.getRelativeTime(threeDaysAgo), equals('3 days ago'));
      });

      test('should return weeks ago', () {
        final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));
        expect(DateTimeUtils.getRelativeTime(twoWeeksAgo), equals('2 weeks ago'));
      });

      test('should return months ago', () {
        final twoMonthsAgo = DateTime.now().subtract(Duration(days: 60));
        expect(DateTimeUtils.getRelativeTime(twoMonthsAgo), equals('2 months ago'));
      });

      test('should return years ago', () {
        final oneYearAgo = DateTime.now().subtract(Duration(days: 365));
        expect(DateTimeUtils.getRelativeTime(oneYearAgo), equals('1 year ago'));
      });

      test('should return future relative times', () {
        final inTwoHours = DateTime.now().add(Duration(hours: 2));
        expect(DateTimeUtils.getRelativeTime(inTwoHours), equals('in 2 hours'));

        final inThreeDays = DateTime.now().add(Duration(days: 3));
        expect(DateTimeUtils.getRelativeTime(inThreeDays), equals('in 3 days'));
      });
    });

    group('isToday', () {
      test('should identify today correctly', () {
        final today = DateTime.now();
        expect(DateTimeUtils.isToday(today), isTrue);

        final yesterday = DateTime.now().subtract(Duration(days: 1));
        expect(DateTimeUtils.isToday(yesterday), isFalse);

        final tomorrow = DateTime.now().add(Duration(days: 1));
        expect(DateTimeUtils.isToday(tomorrow), isFalse);
      });
    });

    group('isTomorrow', () {
      test('should identify tomorrow correctly', () {
        final tomorrow = DateTime.now().add(Duration(days: 1));
        expect(DateTimeUtils.isTomorrow(tomorrow), isTrue);

        final today = DateTime.now();
        expect(DateTimeUtils.isTomorrow(today), isFalse);

        final dayAfter = DateTime.now().add(Duration(days: 2));
        expect(DateTimeUtils.isTomorrow(dayAfter), isFalse);
      });
    });

    group('isThisWeek', () {
      test('should identify dates in current week', () {
        final today = DateTime.now();
        expect(DateTimeUtils.isThisWeek(today), isTrue);

        // Test edge cases based on current day of week
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        expect(DateTimeUtils.isThisWeek(startOfWeek), isTrue);

        final endOfWeek = startOfWeek.add(Duration(days: 6));
        expect(DateTimeUtils.isThisWeek(endOfWeek), isTrue);

        final lastWeek = today.subtract(Duration(days: 7));
        expect(DateTimeUtils.isThisWeek(lastWeek), isFalse);
      });
    });

    group('isThisMonth', () {
      test('should identify dates in current month', () {
        final today = DateTime.now();
        expect(DateTimeUtils.isThisMonth(today), isTrue);

        final firstOfMonth = DateTime(today.year, today.month, 1);
        expect(DateTimeUtils.isThisMonth(firstOfMonth), isTrue);

        final lastMonth = DateTime(today.year, today.month - 1, 15);
        expect(DateTimeUtils.isThisMonth(lastMonth), isFalse);
      });
    });

    group('getDayName', () {
      test('should return correct day name', () {
        final friday = DateTime(2024, 3, 15); // March 15, 2024 is a Friday
        expect(DateTimeUtils.getDayName(friday), equals('Friday'));

        final monday = DateTime(2024, 3, 11); // March 11, 2024 is a Monday
        expect(DateTimeUtils.getDayName(monday), equals('Monday'));
      });
    });

    group('getMonthName', () {
      test('should return correct month name', () {
        final march = DateTime(2024, 3, 15);
        expect(DateTimeUtils.getMonthName(march), equals('March'));

        final december = DateTime(2024, 12, 25);
        expect(DateTimeUtils.getMonthName(december), equals('December'));
      });
    });

    group('getDateRange', () {
      test('should format date range correctly', () {
        final start = DateTime(2024, 3, 10);
        final end = DateTime(2024, 3, 15);
        expect(DateTimeUtils.getDateRange(start, end), equals('Mar 10 - 15, 2024'));

        final differentMonths = DateTime(2024, 4, 5);
        expect(DateTimeUtils.getDateRange(start, differentMonths), equals('Mar 10 - Apr 5, 2024'));

        final differentYears = DateTime(2025, 1, 10);
        expect(DateTimeUtils.getDateRange(start, differentYears), 
               equals('March 10, 2024 - January 10, 2025'));

        final sameDay = DateTime(2024, 3, 10);
        expect(DateTimeUtils.getDateRange(start, sameDay), equals('March 10, 2024'));
      });
    });

    group('getAge', () {
      test('should calculate age correctly', () {
        final today = DateTime.now();
        final birthDate = DateTime(today.year - 25, today.month, today.day);
        expect(DateTimeUtils.getAge(birthDate), equals(25));

        // Test birthday hasn't occurred this year
        final birthDateLater = DateTime(today.year - 25, today.month + 1, today.day);
        expect(DateTimeUtils.getAge(birthDateLater), equals(24));

        // Test birthday already occurred this year
        final birthDateEarlier = DateTime(today.year - 25, today.month - 1, today.day);
        expect(DateTimeUtils.getAge(birthDateEarlier), equals(25));
      });
    });
  });
}
