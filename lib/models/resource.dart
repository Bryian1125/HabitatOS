import 'package:flutter/foundation.dart';

@immutable
class StockEntry {
  const StockEntry(this.time, this.delta, [this.note = '']);

  final DateTime time;
  final int delta;

  /// Optional free-text note the user attached to the change.
  final String note;
}

@immutable
class StockPoint {
  const StockPoint(this.time, this.quantity);

  final DateTime time;
  final int quantity;
}

@immutable
class Resource {
  Resource({
    required this.id,
    required this.name,
    required this.unit,
    required this.initialQuantity,
    required this.createdAt,
    required Iterable<StockEntry> entries,
  }) : entries = List.unmodifiable(_chronological(entries));

  factory Resource.create({
    required String id,
    required String name,
    required String unit,
    required int initialQuantity,
    DateTime? createdAt,
  }) {
    return Resource(
      id: id,
      name: name,
      unit: unit,
      initialQuantity: initialQuantity,
      createdAt: createdAt ?? DateTime.now(),
      entries: const [],
    );
  }

  final String id;
  final String name;
  final String unit;

  /// Stock on hand when the resource was added. Kept separate from [entries]
  /// so a backdated change cannot make the starting stock appear to happen
  /// after the change that consumed it.
  final int initialQuantity;

  final DateTime createdAt;

  final List<StockEntry> entries;

  int get quantity => entries.fold(initialQuantity, (sum, e) => sum + e.delta);

  /// Stock on hand over time, starting with the baseline at the earliest
  /// known moment.
  List<StockPoint> get timeline {
    final origin = entries.isNotEmpty && entries.first.time.isBefore(createdAt)
        ? entries.first.time
        : createdAt;
    var total = initialQuantity;
    return [
      StockPoint(origin, total),
      for (final e in entries) StockPoint(e.time, total += e.delta),
    ];
  }

  /// Average units consumed per day across the tracked span.
  ///
  /// Null while there is nothing to average: no logged change yet, entries
  /// that share a timestamp, or a span shorter than a minute. The span is
  /// measured in seconds so a five hour history is not treated as zero days.
  double? get avgPerDay {
    final points = timeline;
    if (entries.isEmpty) return null;
    final span = points.last.time.difference(points.first.time);
    final days = span.inSeconds / Duration.secondsPerDay;
    if (days < 1 / Duration.minutesPerDay) return null;
    final totalUsed = entries.fold(
      0,
      (sum, e) => sum + (e.delta < 0 ? -e.delta : 0),
    );
    return totalUsed / days;
  }

  Resource withEntry(StockEntry entry) => Resource(
    id: id,
    name: name,
    unit: unit,
    initialQuantity: initialQuantity,
    createdAt: createdAt,
    entries: [...entries, entry],
  );

  Resource withDetails({required String name, required String unit}) =>
      Resource(
        id: id,
        name: name,
        unit: unit,
        initialQuantity: initialQuantity,
        createdAt: createdAt,
        entries: entries,
      );

  bool wouldGoNegative(StockEntry entry) =>
      withEntry(entry).timeline.any((p) => p.quantity < 0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'initialQuantity': initialQuantity,
        'createdAt': createdAt.toIso8601String(),
        'entries': [
          for (final e in entries)
            {
              'time': e.time.toIso8601String(),
              'delta': e.delta,
              'note': e.note,
            },
        ],
      };

  static Resource fromJson(Map<String, dynamic> json) => Resource(
        id: json['id'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String,
        initialQuantity: json['initialQuantity'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        entries: [
          for (final entry in json['entries'] as List<dynamic>? ?? const [])
            StockEntry(
              DateTime.parse((entry as Map<String, dynamic>)['time'] as String),
              entry['delta'] as int,
              entry['note'] as String? ?? '',
            ),
        ],
      );

  static List<StockEntry> _chronological(Iterable<StockEntry> entries) {
    return entries.toList()..sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      return byTime != 0 ? byTime : b.delta.compareTo(a.delta);
    });
  }
}
