import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '刚刚';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    }

    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks周前';
    }

    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months个月前';
    }

    return formatDate(dateTime);
  }

  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return formatTime(dateTime);
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (date == yesterday) {
      return '昨天 ${formatTime(dateTime)}';
    }

    return formatDateTime(dateTime);
  }

  /// 格式化完整日期时间（用于详情页）
  static String formatFull(DateTime dateTime) {
    return formatDateTime(dateTime);
  }
}
