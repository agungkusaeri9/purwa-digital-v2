import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    level: kDebugMode ? Level.debug : Level.info,
  );

  /// Log debug messages
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info messages
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning messages
  static void warn(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error messages
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Mask sensitive key values in map (e.g. pin, password, token)
  static Map<String, dynamic> sanitizeData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    const sensitiveKeys = {'pin', 'password', 'confirm_password', 'token', 'refresh_token', 'access_token'};

    for (final entry in sanitized.entries.toList()) {
      final key = entry.key.toLowerCase();
      if (sensitiveKeys.contains(key)) {
        sanitized[entry.key] = '[REDACTED]';
      } else if (entry.value is Map<String, dynamic>) {
        sanitized[entry.key] = sanitizeData(entry.value as Map<String, dynamic>);
      }
    }
    return sanitized;
  }
}
