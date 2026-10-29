import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habitatos/main.dart';
import 'package:habitatos/models/resource.dart';

void main() {
  group('Resource', () {
    test('create seeds the initial quantity at creation time', () {
      final created = DateTime(2026, 1, 1, 8);
      final resource = Resource.create(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        initialQuantity: 100,
        createdAt: created,
      );

      expect(resource.quantity, 100);
      expect(resource.entries, hasLength(1));
      expect(resource.timeline.single.time, created);
      expect(resource.timeline.single.quantity, 100);
    });

    test('quantity sums every delta', () {
      final resource = Resource.create(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        initialQuantity: 100,
        createdAt: DateTime(2026, 1, 1),
      ).withEntry(StockEntry(DateTime(2026, 1, 2), -10));

      expect(resource.quantity, 90);
    });

    test('entries are kept in chronological order', () {
      final late = DateTime(2026, 1, 5);
      final early = DateTime(2026, 1, 2);
      final resource = Resource(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        entries: [
          StockEntry(late, -5),
          StockEntry(early, 50),
        ],
      );

      expect(resource.entries.map((e) => e.time), [early, late]);
      expect(resource.timeline.map((p) => p.quantity), [50, 45]);
    });

    test('wouldGoNegative rejects an overdraft at any point in history', () {
      final resource = Resource.create(
        id: 'water',
        name: 'Water',
        unit: 'L',
        initialQuantity: 30,
        createdAt: DateTime(2026, 1, 1),
      ).withEntry(StockEntry(DateTime(2026, 1, 2), -20));

      expect(resource.quantity, 10);
      expect(resource.wouldGoNegative(StockEntry(DateTime(2026, 1, 3), -11)), isTrue);
      expect(resource.wouldGoNegative(StockEntry(DateTime(2026, 1, 3), -10)), isFalse);
      expect(resource.wouldGoNegative(StockEntry(DateTime(2026, 1, 3), 5)), isFalse);
    });

    test('withEntry returns a new resource and leaves the original alone', () {
      final original = Resource.create(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        initialQuantity: 10,
      );
      final updated = original.withEntry(StockEntry(DateTime(2026, 2, 1), -4));

      expect(original.entries, hasLength(1));
      expect(updated.entries, hasLength(2));
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.unit, original.unit);
    });
  });

  testWidgets('app boots on the home tab and navigates to resources',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('HabitatOS'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Resources'));
    await tester.pumpAndSettle();

    expect(find.text('Add Resource'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsWidgets);
  });
}
