import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/log_entry.dart';
import '../models/resource.dart';

/// Everything the app keeps between launches.
class HabitatData {
  const HabitatData({this.resources = const [], this.logs = const []});

  final List<Resource> resources;
  final List<LogEntry> logs;

  static const empty = HabitatData();
}

/// Reads and writes [HabitatData] as a single JSON blob in shared preferences.
class StorageService {
  StorageService([this._preferences]);

  static const storageKey = 'habitatos.data.v1';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? await SharedPreferences.getInstance();

  /// Whether anything has ever been saved, so a wiped install is not reseeded
  /// with the default resources.
  Future<bool> hasData() async => (await _prefs).containsKey(storageKey);

  Future<HabitatData> load() async {
    final prefs = await _prefs;
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return HabitatData.empty;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return HabitatData(
        resources: [
          for (final json in decoded['resources'] as List<dynamic>? ?? const [])
            Resource.fromJson(json as Map<String, dynamic>),
        ],
        logs: [
          for (final json in decoded['logs'] as List<dynamic>? ?? const [])
            LogEntry.fromJson(json as Map<String, dynamic>),
        ],
      );
    } on Object {
      // A corrupt or outdated blob should not stop the app from starting.
      return HabitatData.empty;
    }
  }

  Future<void> save(HabitatData data) async {
    final prefs = await _prefs;
    await prefs.setString(
      storageKey,
      jsonEncode({
        'resources': [for (final r in data.resources) r.toJson()],
        'logs': [for (final l in data.logs) l.toJson()],
      }),
    );
  }

  /// Wipes the stored blob. A later [hasData] still reports true, so the
  /// default resources are not seeded again.
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.setString(
      storageKey,
      jsonEncode({'resources': const [], 'logs': const []}),
    );
  }
}
