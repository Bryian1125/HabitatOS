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
    Resource.create(id: 'food_1', name: 'Food', unit: 'kg', initialQuantity: 100),
    Resource.create(id: 'water_1', name: 'Water', unit: 'L', initialQuantity: 100),
  ];

  List<Widget> get _pages => [
    HomeScreen(logs: _resourceLogs, resources: _resources),
    ResourcesScreen(
      onEditLog: _addResourceLog,
      resources: _resources,
      onAdd: _addResource,
      onLog: _logResource,
      onDelete: _deleteResource,
    ),
    LogsScreen(logs: _resourceLogs),
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

  final List<String> _navLabels = const [
    'Home',
    'Resources',
    'Logs',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Side panel
        Container(
          width: 240,
          color: const Color(0xFF0A0A0A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Text(
                  'HabitatOS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _navLabels.length,
                  itemBuilder: (context, index) {
                    final selected = index == _selectedIndex;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text(
                          _navLabels[index],
                          style: TextStyle(
                            color: selected ? AppColors.accent : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: _SidePanelClock(),
              ),
            ],
          ),
        ),
        // Content area
        Expanded(
          child: Container(
            color: AppColors.background,
            child: _pages[_selectedIndex],
          ),
        ),
      ],
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
