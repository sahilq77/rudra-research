import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  /// Debug log (lightweight info)
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'DEBUG',
        level: 0, // Debug level
      );
    }
  }

  /// Info log
  static void i(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'INFO',
        level: 800, // Info level
      );
    }
  }

  /// Warning log
  static void w(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'WARN',
        level: 900, // Warning level
      );
    }
  }

  /// Error log (with optional error/stack)
  static void e(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'ERROR',
        level: 1000, // Error level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fatal log (highest severity)
  static void f(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'FATAL',
        level: 1200, // Fatal level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
