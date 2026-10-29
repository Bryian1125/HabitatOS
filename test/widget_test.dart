import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habitatos/main.dart';
import 'package:habitatos/models/resource.dart';

void main() {
  group('Resource', () {
    test('create keeps the initial quantity as a baseline, not a delta', () {
      final created = DateTime(2026, 1, 1, 8);
      final resource = Resource.create(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        initialQuantity: 100,
        createdAt: created,
      );

      expect(resource.quantity, 100);
      expect(resource.initialQuantity, 100);
      expect(resource.entries, isEmpty);
      expect(resource.timeline.single.time, created);
      expect(resource.timeline.single.quantity, 100);
    });

    test('a change backdated before creation still stacks on the baseline', () {
      final created = DateTime(2026, 1, 10);
      final resource = Resource.create(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        initialQuantity: 100,
        createdAt: created,
      ).withEntry(StockEntry(DateTime(2026, 1, 5), -10));

      // The old model made the starting 100 sort after the -10 entry, so the
      // timeline read -10 then 90.
      expect(resource.quantity, 90);
      expect(resource.timeline.map((p) => p.quantity), [100, 90]);
      expect(resource.timeline.first.time, DateTime(2026, 1, 5));
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
        initialQuantity: 10,
        createdAt: DateTime(2026, 1, 1),
        entries: [StockEntry(late, -5), StockEntry(early, 50)],
      );

      expect(resource.entries.map((e) => e.time), [early, late]);
      expect(resource.timeline.map((p) => p.quantity), [10, 60, 55]);
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
      expect(
        resource.wouldGoNegative(StockEntry(DateTime(2026, 1, 3), -11)),
        isTrue,
      );
      expect(
        resource.wouldGoNegative(StockEntry(DateTime(2026, 1, 3), -10)),
        isFalse,
      );
      expect(
        resource.wouldGoNegative(StockEntry(DateTime(2026, 1, 3), 5)),
        isFalse,
      );
    });

    test('withEntry returns a new resource and leaves the original alone', () {
      final original = Resource.create(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        initialQuantity: 10,
      );
      final updated = original.withEntry(StockEntry(DateTime(2026, 2, 1), -4));

      expect(original.entries, isEmpty);
      expect(updated.entries, hasLength(1));
      expect(updated.initialQuantity, original.initialQuantity);
      expect(updated.createdAt, original.createdAt);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.unit, original.unit);
    });

    test('avgPerDay divides usage by the elapsed span, not whole days', () {
      final resource =
          Resource.create(
                id: 'food',
                name: 'Food',
                unit: 'kg',
                initialQuantity: 100,
                createdAt: DateTime(2026, 1, 1, 0),
              )
              .withEntry(StockEntry(DateTime(2026, 1, 1, 3), -6))
              .withEntry(StockEntry(DateTime(2026, 1, 1, 6), -6));

      // 12 kg over 6 hours is 48 kg/day. The old whole-day maths saw a zero
      // day span and hid the figure entirely.
      expect(resource.avgPerDay, closeTo(48, 0.001));
    });

    test('avgPerDay needs two entries on different timestamps', () {
      final created = DateTime(2026, 1, 1);
      final fresh = Resource.create(
        id: 'a',
        name: 'A',
        unit: 'kg',
        initialQuantity: 5,
        createdAt: created,
      );
      final sameTime = fresh.withEntry(StockEntry(created, -1));

      expect(fresh.avgPerDay, isNull);
      expect(sameTime.avgPerDay, isNull);
    });

    test('a note stays attached to its entry', () {
      final resource = Resource.create(
        id: 'food',
        name: 'Food',
        unit: 'kg',
        initialQuantity: 10,
        createdAt: DateTime(2026, 1, 1),
      ).withEntry(StockEntry(DateTime(2026, 1, 2), -3, 'dried food'));

      expect(resource.entries.single.note, 'dried food');
      expect(resource.entries.single.delta, -3);
    });
  });

  testWidgets('app boots on the home tab and navigates to resources', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('HabitatOS'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Resources'));
    await tester.pumpAndSettle();

    expect(find.text('Add Resource'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsWidgets);
  });

  testWidgets('sidebar collapses to an icon rail on a narrow window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('HabitatOS'), findsNothing);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Add Resource'), findsOneWidget);
  });
}
