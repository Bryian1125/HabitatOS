import 'package:flutter/material.dart';

import '../theme.dart';

/// Dashboard (Home) screen. Layout only for now.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _MissionHeader(),
        SizedBox(height: 16),
        _ChartPlaceholder(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _MissionHeader extends StatelessWidget {
  const _MissionHeader();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Mission Alpha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('Simulated - 1 min/day', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Day 12 of 30', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(value: 0.4, color: AppColors.accent, backgroundColor: AppColors.border),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Food supply 14D', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('below optimal consumption line!', style: TextStyle(color: AppColors.critical)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: const Text('chart placeholder', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}