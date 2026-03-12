import 'package:logger/logger.dart';
import '../utils/sensitive_data_masker.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._internal();
  static AppLogger get instance => _instance;

  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );
  }

  late final Logger _logger;

  void verbose(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.t(
      SensitiveDataMasker.mask(message),
      error: error != null ? SensitiveDataMasker.mask(error.toString()) : null,
      stackTrace: stackTrace,
    );
  }

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(
      SensitiveDataMasker.mask(message),
      error: error != null ? SensitiveDataMasker.mask(error.toString()) : null,
      stackTrace: stackTrace,
    );
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(
      SensitiveDataMasker.mask(message),
      error: error != null ? SensitiveDataMasker.mask(error.toString()) : null,
      stackTrace: stackTrace,
    );
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(
      SensitiveDataMasker.mask(message),
      error: error != null ? SensitiveDataMasker.mask(error.toString()) : null,
      stackTrace: stackTrace,
    );
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(
      SensitiveDataMasker.mask(message),
      error: error != null ? SensitiveDataMasker.mask(error.toString()) : null,
      stackTrace: stackTrace,
    );
  }

  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(
      SensitiveDataMasker.mask(message),
      error: error != null ? SensitiveDataMasker.mask(error.toString()) : null,
      stackTrace: stackTrace,
    );
  }
}
