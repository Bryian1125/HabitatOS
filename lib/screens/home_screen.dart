import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/log_entry.dart';
import 'resources_screen.dart';
import '../theme.dart';
import '../gradient_border.dart';
import '../utils/format.dart';
import '../widgets/stock_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.logs = const [],
    this.resources = const [],
  });

  final List<LogEntry> logs;
  final List<Resource> resources;

  /// The resource with the most logged entries; ties go to the most recently edited.
  /// Null until a resource has activity beyond its initial quantity.
  Resource? get _mostActive {
    final active = resources.where((r) => r.entries.isNotEmpty).toList();
    if (active.isEmpty) return null;
    return active.reduce((a, b) {
      final byEntries = a.entries.length.compareTo(b.entries.length);
      if (byEntries != 0) return byEntries > 0 ? a : b;
      return a.entries.last.time.isAfter(b.entries.last.time) ? a : b;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: h * 5 / 7,
          child: _ResourcePanel(resource: _mostActive),
        ),
        const SizedBox(height: 16),
        // Bottom row: logs full width
        GradientBorder(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOGS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                if (logs.isEmpty)
                  const Text(
                    'No entries yet. Log a stock change from Resources.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else
                  ...logs.reversed
                      .take(12)
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '${formatDateTime(entry.time)}: ${entry.message}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResourcePanel extends StatelessWidget {
  const _ResourcePanel({this.resource});

  final Resource? resource;

  @override
  Widget build(BuildContext context) {
    final resource = this.resource;
    return GradientBorder(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource == null
                  ? 'NO DATA'
                  : '${resource.name.toUpperCase()} (${resource.unit})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (resource == null)
              const Expanded(child: _EmptyChart())
            else ...[
              Text(
                '${resource.quantity} ${resource.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              if (resource.avgPerDay case final avg?)
                Text(
                  'AVG: ${avg.toStringAsFixed(1)} ${resource.unit}/d',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(child: StockChart(resource: resource)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  static const _yDivisions = 4;
  static const _maxY = 100.0;
  static const _spanHours = 1.0;
  static const _xDivisions = 3;

  static const _axisStyle = TextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: _spanHours,
          minY: 0,
          maxY: _maxY,
          lineBarsData: const [],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _maxY / _yDivisions,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: _maxY / _yDivisions,
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString(), style: _axisStyle),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: _spanHours / _xDivisions,
                getTitlesWidget: (value, meta) {
                  final t = now.add(Duration(minutes: (value * 60).round()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      formatTime(t),
                      style: _axisStyle,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

