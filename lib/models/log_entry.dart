import 'package:flutter/foundation.dart';

/// A single user-facing history record.
///
/// Kept as structured data instead of a pre-formatted string so screens can
/// order, filter, link and format entries without re-parsing text.
@immutable
class LogEntry {
  const LogEntry({
    required this.time,
    required this.message,
    this.resourceId,
  });

  /// When the logged change happened (the user-picked date, not the import
  /// time).
  final DateTime time;

  /// Human readable description, e.g. `-10 kg, dried food`.
  final String message;

  /// The resource this entry belongs to, when it is a stock change.
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
