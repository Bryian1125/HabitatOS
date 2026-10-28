import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.logs = const []});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Empty panels — data will go here after CRUD setup
        _DataPanel(
          title: 'Most updated resource',
          subtitle: 'visualization based on activity',
          child: Column(
            children: [
              Text(
                logs.isNotEmpty ? (() { final s = logs.first; final idx = s.indexOf(': '); final msg = idx != -1 ? s.substring(idx + 2).trim() : s; final editIdx = msg.indexOf('Edit '); return editIdx != -1 ? msg.substring(editIdx + 5).trim().split(' ').first : msg.split(' ').first; })() : 'No resource',
                style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 120,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [FlSpot(0, 100), FlSpot(1, 80), FlSpot(2, 60), FlSpot(3, 70)],
                        isCurved: false,
                        color: AppColors.accent,
                      ),
                    ],
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Bottom row: supplies + logs
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Expanded(child: Text('Food supply', style: TextStyle(color: AppColors.textSecondary))),
                          Expanded(child: Text('Water supply', style: TextStyle(color: AppColors.textSecondary))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Expanded(child: Text('21D', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace'))),
                          Expanded(child: Text('14D', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace'))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Expanded(child: Text('Remaining', style: TextStyle(color: AppColors.textSecondary))),
                          Expanded(child: Text('Remaining', style: TextStyle(color: AppColors.textSecondary))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LOGS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      ...logs.reversed.take(5).map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(entry, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DataPanel extends StatelessWidget {
  const _DataPanel({required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Spacer(),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: AppColors.critical),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}