import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志条目
class LogEntry {
  final DateTime timestamp;
  final String name;
  final String message;
  final LogLevel level;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.name,
    required this.message,
    this.level = LogLevel.info,
    this.error,
    this.stackTrace,
  });

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    final millisecond = timestamp.millisecond.toString().padLeft(3, '0');
    return '$hour:$minute:$second.$millisecond';
  }

  String get levelString {
    switch (level) {
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[$formattedTime] $levelString/$name: $message');
    if (error != null) {
      buffer.write('\nError: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }
}

/// 日志服务
/// 
/// 用于收集和管理应用日志，支持在系统日志页面展示
class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  // 最多保存1000条日志
  static const int _maxLogCount = 1000;
  
  final List<LogEntry> _logs = [];
  final _logController = ValueNotifier<List<LogEntry>>([]);

  /// 日志流
  ValueNotifier<List<LogEntry>> get logStream => _logController;

  /// 获取所有日志
  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// 记录日志
  void log(
    String name,
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      name: name,
      message: message,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(entry);
    
    // 限制日志数量
    if (_logs.length > _maxLogCount) {
      _logs.removeAt(0);
    }

    _logController.value = List.unmodifiable(_logs);

    // 同时输出到控制台
    if (kDebugMode) {
      print(entry.toString());
    }
  }

  /// 记录调试日志
  void d(String name, String message) {
    log(name, message, level: LogLevel.debug);
  }

  /// 记录信息日志
  void i(String name, String message) {
    log(name, message, level: LogLevel.info);
  }

  /// 记录警告日志
  void w(String name, String message) {
    log(name, message, level: LogLevel.warning);
  }

  /// 记录错误日志
  void e(String name, String message, {Object? error, StackTrace? stackTrace}) {
    log(name, message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  }

  /// 清空日志
  void clear() {
    _logs.clear();
    _logController.value = [];
  }

  /// 获取格式化的所有日志文本
  String getAllLogsText() {
    return _logs.map((e) => e.toString()).join('\n\n');
  }

  /// 获取过滤后的日志
  List<LogEntry> getFilteredLogs({
    String? searchQuery,
    LogLevel? minLevel,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return _logs.where((log) {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (!log.message.toLowerCase().contains(searchQuery.toLowerCase()) &&
            !log.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (minLevel != null && log.level.index < minLevel.index) {
        return false;
      }
      if (startTime != null && log.timestamp.isBefore(startTime)) {
        return false;
      }
      if (endTime != null && log.timestamp.isAfter(endTime)) {
        return false;
      }
      return true;
    }).toList();
  }
}

/// 全局日志服务实例
final logService = LogService();
