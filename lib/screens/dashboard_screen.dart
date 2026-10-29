import 'package:flutter/material.dart';
import 'dart:async';

import '../models/log_entry.dart';
import '../services/storage.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'home_screen.dart';
import 'resources_screen.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = StorageService();
  int _selectedIndex = 0;
  final List<LogEntry> _resourceLogs = [];
  final List<Resource> _resources = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hadStoredData = await _storage.hasData();
    final data = await _storage.load();
    if (!mounted) return;

    setState(() {
      _resources
        ..clear()
        ..addAll(hadStoredData ? data.resources : _seedResources());
      _resourceLogs
        ..clear()
        ..addAll(data.logs);
      _loaded = true;
    });

    if (!hadStoredData) await _save();
  }

  /// Starting stock for a brand new install.
  List<Resource> _seedResources() => [
        Resource.create(
          id: 'food_1',
          name: 'Food',
          unit: 'kg',
          initialQuantity: 100,
        ),
        Resource.create(
          id: 'water_1',
          name: 'Water',
          unit: 'L',
          initialQuantity: 100,
        ),
      ];

  Future<void> _save() => _storage.save(
        HabitatData(resources: _resources, logs: _resourceLogs),
      );

  void _persist() => unawaited(_save());

  List<Widget> get _pages => [
    HomeScreen(logs: _resourceLogs, resources: _resources),
    ResourcesScreen(
      resources: _resources,
      onAdd: _addResource,
      onLog: _applyStockChange,
      onDelete: _deleteResource,
      onRename: _renameResource,
    ),
    LogsScreen(
      logs: _resourceLogs,
      onDeleteLog: _deleteLog,
      onClearLogs: _clearLogs,
    ),
    const SettingsScreen(),
  ];

  void _addResource(Resource resource) {
    setState(() => _resources.add(resource));
    _persist();
  }

  void _applyStockChange(String id, StockEntry entry, LogEntry log) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final previous = _resources[index];
    setState(() {
      _resources[index] = previous.withEntry(entry);
      _resourceLogs.add(log);
    });
    _persist();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(log.message),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => _revertStockChange(previous, log),
          ),
        ),
      );
  }

  void _revertStockChange(Resource previous, LogEntry log) {
    setState(() {
      final index = _resources.indexWhere((r) => r.id == previous.id);
      if (index != -1) _resources[index] = previous;
      _resourceLogs.remove(log);
    });
    _persist();
  }

  void _renameResource(String id, String name, String unit) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;
    setState(() {
      _resources[index] = _resources[index].withDetails(name: name, unit: unit);
    });
    _persist();
  }

  void _deleteResource(String id) {
    setState(() {
      _resources.removeWhere((r) => r.id == id);
      _resourceLogs.removeWhere((log) => log.resourceId == id);
    });
    _persist();
  }

  void _deleteLog(LogEntry entry) {
    setState(() => _resourceLogs.remove(entry));
    _persist();
  }

  void _clearLogs() {
    setState(() => _resourceLogs.clear());
    _persist();
  }

  final List<String> _navLabels = const [
    'Home',
    'Resources',
    'Logs',
    'Settings',
  ];

  final List<IconData> _navIcons = const [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.receipt_long_outlined,
    Icons.settings_outlined,
  ];

  /// The full sidebar needs room for its labels; below this width it collapses
  /// to an icon rail so the content area keeps a usable size.
  static const _fullSidebarBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= _fullSidebarBreakpoint;
        return Row(
          children: [
            _buildSidePanel(expanded: expanded),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: _loaded
                    ? IndexedStack(index: _selectedIndex, children: _pages)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidePanel({required bool expanded}) {
    return Container(
      width: expanded ? 240 : 72,
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment:
            expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: expanded
                ? const EdgeInsets.fromLTRB(24, 32, 24, 8)
                : const EdgeInsets.fromLTRB(8, 32, 8, 8),
            child: expanded
                ? const Text(
                    'HabitatOS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.eco_outlined,
                    color: AppColors.textPrimary, size: 26),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _navLabels.length,
              itemBuilder: (context, index) {
                final selected = index == _selectedIndex;
                final color =
                    selected ? AppColors.accent : AppColors.textSecondary;
                final icon = Icon(
                  _navIcons[index],
                  size: 20,
                  color: color,
                );
                return InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: expanded ? 24 : 0,
                      vertical: 12,
                    ),
                    child: expanded
                        ? Row(
                            children: [
                              icon,
                              const SizedBox(width: 12),
                              Text(
                                _navLabels[index],
                                style: TextStyle(
                                  color: color,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          )
                        : Tooltip(
                            message: _navLabels[index],
                            child: Center(child: icon),
                          ),
                  ),
                );
              },
            ),
          ),
          if (expanded)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: _SidePanelClock(),
            ),
        ],
      ),
    );
  }
}

class _SidePanelClock extends StatefulWidget {
  const _SidePanelClock();

  @override
  State<_SidePanelClock> createState() => _SidePanelClockState();
}

class _SidePanelClockState extends State<_SidePanelClock> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'DMY:${two(now.day)}.${two(now.month)}.${now.year}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
