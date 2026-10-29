import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habitatos/models/log_entry.dart';
import 'package:habitatos/models/resource.dart';
import 'package:habitatos/services/storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('round trips resources and logs through storage', () async {
    final storage = StorageService();
    expect(await storage.hasData(), isFalse);

    final resource = Resource.create(
      id: 'food',
      name: 'Food',
      unit: 'kg',
      initialQuantity: 100,
      createdAt: DateTime(2026, 1, 1, 8, 30),
    ).withEntry(StockEntry(DateTime(2026, 1, 2, 9), -10, 'dried food'));
    final log = LogEntry(
      time: DateTime(2026, 1, 2, 9),
      message: 'Edit Food: -10 kg, dried food',
      resourceId: 'food',
    );

    await storage.save(HabitatData(resources: [resource], logs: [log]));

    expect(await storage.hasData(), isTrue);

    final loaded = await StorageService().load();
    final loadedResource = loaded.resources.single;

    expect(loaded.resources, hasLength(1));
    expect(loadedResource.id, 'food');
    expect(loadedResource.name, 'Food');
    expect(loadedResource.unit, 'kg');
    expect(loadedResource.initialQuantity, 100);
    expect(loadedResource.createdAt, DateTime(2026, 1, 1, 8, 30));
    expect(loadedResource.quantity, 90);
    expect(loadedResource.entries.single.note, 'dried food');

    expect(loaded.logs.single.message, 'Edit Food: -10 kg, dried food');
    expect(loaded.logs.single.resourceId, 'food');
    expect(loaded.logs.single.time, DateTime(2026, 1, 2, 9));
  });

  test('clear empties the data but does not look like a fresh install',
      () async {
    final storage = StorageService();
    await storage.save(HabitatData(
      resources: [
        Resource.create(id: 'a', name: 'A', unit: 'kg', initialQuantity: 1),
      ],
    ));

    await storage.clear();

    expect(await storage.hasData(), isTrue);
    final loaded = await storage.load();
    expect(loaded.resources, isEmpty);
    expect(loaded.logs, isEmpty);
  });

  test('corrupt stored data is ignored instead of crashing', () async {
    SharedPreferences.setMockInitialValues({
      StorageService.storageKey: 'this is not json',
    });

    final loaded = await StorageService().load();
    expect(loaded.resources, isEmpty);
    expect(loaded.logs, isEmpty);
  });
}
