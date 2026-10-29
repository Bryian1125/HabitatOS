import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import '../models/log_entry.dart';
import '../theme.dart';
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
  int _selectedIndex = 0;
  final List<LogEntry> _resourceLogs = [];

  final List<Resource> _resources = [
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

  List<Widget> get _pages => [
    HomeScreen(logs: _resourceLogs, resources: _resources),
    ResourcesScreen(
      onEditLog: _addResourceLog,
      resources: _resources,
      onAdd: _addResource,
      onLog: _logResource,
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
  }

  void _logResource(String id, StockEntry entry) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;
    setState(() {
      _resources[index] = _resources[index].withEntry(entry);
    });
  }

  void _renameResource(String id, String name, String unit) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;
    setState(() {
      _resources[index] = _resources[index].withDetails(name: name, unit: unit);
    });
  }

  void _deleteResource(String id) {
    setState(() {
      _resources.removeWhere((r) => r.id == id);
      _resourceLogs.removeWhere((log) => log.resourceId == id);
    });
  }

  void _addResourceLog(LogEntry entry) {
    setState(() {
      _resourceLogs.add(entry);
    });
  }

  void _deleteLog(LogEntry entry) {
    setState(() => _resourceLogs.remove(entry));
  }

  void _clearLogs() {
    setState(() => _resourceLogs.clear());
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
                child: IndexedStack(index: _selectedIndex, children: _pages),
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
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

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
              '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}',
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'DMY:${_pad(now.day)}.${_pad(now.month)}.${now.year}',
            style: GoogleFonts.jetBrainsMono(
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
