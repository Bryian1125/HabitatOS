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
