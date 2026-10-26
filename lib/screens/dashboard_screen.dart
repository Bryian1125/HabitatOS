import 'package:flutter/material.dart';

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

  final List<Widget> _pages = const [
    HomeScreen(),
    ResourcesScreen(),
    LogsScreen(),
    SettingsScreen(),
  ];

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
          color: const Color(0xFF0D1117),
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
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      title: Text(
                        _navLabels[index],
                        style: TextStyle(
                          color: selected ? AppColors.accent : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
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
