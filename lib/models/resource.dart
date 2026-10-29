import 'package:flutter/foundation.dart';

@immutable
class StockEntry {
  const StockEntry(this.time, this.delta);

  final DateTime time;
  final int delta;
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
      entries: [StockEntry(createdAt ?? DateTime.now(), initialQuantity)],
    );
  }

  final String id;
  final String name;
  final String unit;

  final List<StockEntry> entries;

  int get quantity => entries.fold(0, (sum, e) => sum + e.delta);

  List<StockPoint> get timeline {
    var total = 0;
    return [for (final e in entries) StockPoint(e.time, total += e.delta)];
  }

  /// Average units consumed per day across the logged span.
  ///
  /// Null while there is nothing to average: fewer than two entries, entries
  /// that share a timestamp, or a span shorter than a minute. The span is
  /// measured in seconds so a five hour history is not treated as zero days.
  double? get avgPerDay {
    if (entries.length < 2) return null;
    final span = entries.last.time.difference(entries.first.time);
    final days = span.inSeconds / Duration.secondsPerDay;
    if (days < 1 / Duration.minutesPerDay) return null;
    final totalUsed =
        entries.fold(0, (sum, e) => sum + (e.delta < 0 ? -e.delta : 0));
    return totalUsed / days;
  }

  Resource withEntry(StockEntry entry) => Resource(
        id: id,
        name: name,
        unit: unit,
        entries: [...entries, entry],
      );

  bool wouldGoNegative(StockEntry entry) =>
      withEntry(entry).timeline.any((p) => p.quantity < 0);

  static List<StockEntry> _chronological(Iterable<StockEntry> entries) {
    return entries.toList()
      ..sort((a, b) {
        final byTime = a.time.compareTo(b.time);
        return byTime != 0 ? byTime : b.delta.compareTo(a.delta);
      });
  }
}
