import 'package:flutter/foundation.dart';

/// Structured history record — avoids string parsing.
@immutable
class LogEntry {
  const LogEntry({required this.time, required this.message, this.resourceId});

  final DateTime time;
  final String message;
  final String? resourceId;

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'message': message,
    'resourceId': resourceId,
  };

  static LogEntry fromJson(Map<String, dynamic> json) => LogEntry(
    time: DateTime.parse(json['time'] as String),
    message: json['message'] as String,
    resourceId: json['resourceId'] as String?,
  );
}
