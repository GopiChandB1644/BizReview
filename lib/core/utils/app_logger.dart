import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug('DEBUG', '🔍'),
  info('INFO', 'ℹ️'),
  backend('BACKEND', '🚀'),
  data('DATA', '📦'),
  warning('WARN', '⚠️'),
  error('ERROR', '❌');

  final String label;
  final String emoji;
  const LogLevel(this.label, this.emoji);
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final dynamic data;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.data,
    this.error,
    this.stackTrace,
  });

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  String get dataString {
    if (data == null) return '';
    if (data is Map || data is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }
}

class AppLogger {
  static final List<LogEntry> _history = [];
  static final StreamController<LogEntry> _logStreamController =
      StreamController<LogEntry>.broadcast();

  static const int maxHistory = 200;

  static List<LogEntry> get history => List.unmodifiable(_history);
  static Stream<LogEntry> get logStream => _logStreamController.stream;

  static void clear() {
    _history.clear();
  }

  /// General Information log
  static void i(String message, {String tag = 'APP', dynamic data}) {
    _log(LogLevel.info, tag, message, data: data);
  }

  /// Debug log
  static void d(String message, {String tag = 'DEBUG', dynamic data}) {
    _log(LogLevel.debug, tag, message, data: data);
  }

  /// Warning log
  static void w(String message, {String tag = 'WARN', dynamic data}) {
    _log(LogLevel.warning, tag, message, data: data);
  }

  /// Error log with optional exception and stack trace
  static void e(
    String message, {
    String tag = 'ERROR',
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      tag,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Dedicated Backend Trigger log for Firestore reads, writes, and cloud events
  static void backend(
    String action, {
    required String collection,
    String? docId,
    Map<String, dynamic>? payload,
    String? result,
  }) {
    final docPart = docId != null ? '/$docId' : '';
    final msg = '[$action] ➔ $collection$docPart ${result != null ? "➔ $result" : ""}';

    _log(
      LogLevel.backend,
      'FIRESTORE',
      msg,
      data: payload,
    );
  }

  /// Data payload inspection log
  static void data(String title, dynamic data, {String tag = 'DATA'}) {
    _log(LogLevel.data, tag, title, data: data);
  }

  static void _log(
    LogLevel level,
    String tag,
    String message, {
    dynamic data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );

    // Keep fixed buffer size
    _history.insert(0, entry);
    if (_history.length > maxHistory) {
      _history.removeLast();
    }

    _logStreamController.add(entry);

    // Console output with clear format
    final buffer = StringBuffer();
    buffer.write('${entry.level.emoji} [${entry.formattedTime}] [${entry.level.label}] [$tag] $message');

    if (data != null) {
      buffer.write('\n   📦 Payload: ${entry.dataString}');
    }

    if (error != null) {
      buffer.write('\n   ❌ Error Details: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n   📜 StackTrace: \n$stackTrace');
    }

    debugPrint(buffer.toString());
  }
}
