import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/resource.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Stock-on-hand line chart for one resource.
///
/// Shared by the home panel and the resources list so both stay in step.
class StockChart extends StatelessWidget {
  const StockChart({super.key, required this.resource});

  final Resource resource;

  static const _yDivisions = 4;
  static const _xDivisions = 3;
  static const _msPerHour = Duration.millisecondsPerHour;

  static const _minSpanHours = 1 / 60;

  static const _axisStyle = TextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final timeline = resource.timeline;
    if (timeline.isEmpty) {
      return const Center(
        child: Text(
          'No history yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final origin = timeline.first.time;
    double xOf(DateTime t) => t.difference(origin).inMilliseconds / _msPerHour;
    DateTime timeAt(double x) =>
        origin.add(Duration(milliseconds: (x * _msPerHour).round()));

    final spots = [
      for (final p in timeline) FlSpot(xOf(p.time), p.quantity.toDouble()),
    ];

    final nowX = xOf(DateTime.now());
    final hasTail = nowX > spots.last.x;
    if (hasTail) spots.add(FlSpot(nowX, spots.last.y));

    final tailX = spots.last.x;
    final maxX = max(tailX, _minSpanHours);
    final showClockTime = maxX < 24; // short span: HH:mm, otherwise MM-dd

    final peak = timeline.fold<int>(1, (m, p) => max(m, p.quantity));
    final yInterval = (peak / _yDivisions).ceil();
    final maxY = (yInterval * _yDivisions).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: AppColors.accent,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => !(hasTail && spot.x == tailX),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval.toDouble(),
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
              interval: yInterval.toDouble(),
              getTitlesWidget: (value, meta) =>
                  Text(value.toInt().toString(), style: _axisStyle),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: maxX / _xDivisions,
              getTitlesWidget: (value, meta) {
                final t = timeAt(value);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    showClockTime ? formatTime(t) : formatDate(t),
                    style: _axisStyle,
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            tooltipMargin: 8,
            getTooltipItems: (touched) => [
              for (final spot in touched)
                LineTooltipItem(
                  '${formatDateTime(timeAt(spot.x))}\n'
                  '${spot.y.toInt()} ${resource.unit}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
