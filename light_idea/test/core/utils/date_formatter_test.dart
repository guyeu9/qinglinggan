import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('formatRelative', () {
      test('should return "刚刚" for less than 1 minute', () {
        final now = DateTime.now();
        expect(DateFormatter.formatRelative(now), '刚刚');
      });

      test('should return minutes ago for less than 1 hour', () {
        final date = DateTime.now().subtract(const Duration(minutes: 30));
        expect(DateFormatter.formatRelative(date), contains('分钟前'));
      });

      test('should return hours ago for less than 24 hours', () {
        final date = DateTime.now().subtract(const Duration(hours: 5));
        expect(DateFormatter.formatRelative(date), contains('小时前'));
      });

      test('should return days ago for less than 7 days', () {
        final date = DateTime.now().subtract(const Duration(days: 3));
        expect(DateFormatter.formatRelative(date), contains('天前'));
      });

      test('should return weeks ago for less than 30 days', () {
        final date = DateTime.now().subtract(const Duration(days: 14));
        expect(DateFormatter.formatRelative(date), contains('周前'));
      });

      test('should return months ago for less than 365 days', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        expect(DateFormatter.formatRelative(date), contains('个月前'));
      });

      test('should return formatted date for more than 365 days', () {
        final date = DateTime.now().subtract(const Duration(days: 400));
        expect(DateFormatter.formatRelative(date), contains('-'));
      });
    });

    group('formatDateTime', () {
      test('should format date and time correctly', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        expect(DateFormatter.formatDateTime(date), '2024-03-15 14:30');
      });
    });

    group('formatDate', () {
      test('should format date correctly', () {
        final date = DateTime(2024, 3, 15);
        expect(DateFormatter.formatDate(date), '2024-03-15');
      });
    });

    group('formatTime', () {
      test('should format time as HH:mm', () {
        final date = DateTime(2024, 1, 1, 9, 5);
        expect(DateFormatter.formatTime(date), '09:05');
      });
    });

    group('formatFull', () {
      test('should format full date time', () {
        final date = DateTime(2024, 1, 15, 10, 30);
        expect(DateFormatter.formatFull(date), '2024-01-15 10:30');
      });
    });

    group('formatChatTime', () {
      test('should return time only for today', () {
        final now = DateTime.now();
        expect(DateFormatter.formatChatTime(now), contains(':'));
      });

      test('should return "昨天" for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateFormatter.formatChatTime(yesterday), contains('昨天'));
      });
    });
  });
}
