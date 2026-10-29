import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'resources_screen.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.logs = const []});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Empty panels — data will go here after CRUD setup
        SizedBox(
          height: h * 5 / 7,
          child: _DataPanel(
          title: '',
          subtitle: '',
          child: logs.isNotEmpty ? _ResourceCard(
            resource: Resource.create(id: 'dummy', name: 'Food', unit: 'kg', initialQuantity: 100),
            onEdit: () {},
          ) : Container(height: 180, color: AppColors.card),
        ),
        ),
        const SizedBox(height: 16),
        // Bottom row: logs full width
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.grey.shade600, const Color(0xFF333333)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(1.5),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOGS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 20),
                  ...logs.reversed.take(12).map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(entry, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  )),
                ],
              ),
            ),
          ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.grey.shade600, const Color(0xFF333333)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.5),
            ),
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
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({super.key, required this.resource, required this.onEdit});

  final Resource resource;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.grey.shade600, const Color(0xFF333333)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.5),
            ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${resource.name.toUpperCase()} (${resource.unit})',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: AppColors.accent),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${resource.quantity} ${resource.unit}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Builder(builder: (context) {
              final entries = resource.entries;
              if (entries.length < 2) return const SizedBox.shrink();
              final first = entries.first.time;
              final last = entries.last.time;
              final days = last.difference(first).inDays;
              if (days <= 0) return const SizedBox.shrink();
              final totalUsed = entries.fold(0, (sum, e) => sum + (e.delta < 0 ? -e.delta : 0));
              final avg = totalUsed / days;
              return Text('AVG: ${avg.toStringAsFixed(1)} ${resource.unit}/d',
                style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500));
            }),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: _StockChart(resource: resource),
            ),
          ],
        ),
      ),
    ));
  }
}

class _StockChart extends StatelessWidget {
  const _StockChart({required this.resource});

  final Resource resource;

  static const _yDivisions = 4;
  static const _xDivisions = 3;
  static const _msPerHour = Duration.millisecondsPerHour;

  static const _minSpanHours = 1 / 60;

  static const _axisStyle = TextStyle(fontSize: 10, color: AppColors.textSecondary);

  @override
  Widget build(BuildContext context) {
    final timeline = resource.timeline;
    if (timeline.isEmpty) {
      return const Center(
        child: Text('No history yet', style: TextStyle(color: AppColors.textSecondary)),
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

    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16),
      child: LineChart(
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
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      showClockTime ? '${t.hour}:${t.minute.toString().padLeft(2, '0')}' : '${t.month}/${t.day}',
                      style: _axisStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => [
                for (final spot in touched)
                  LineTooltipItem(
                    '${timeAt(spot.x).toString()}\n${spot.y.toInt()} ${resource.unit}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


