import 'package:flutter/material.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _MissionHeader(),
        SizedBox(height: 16),
        _ActiveAlertsPanel(),
        SizedBox(height: 16),
        _ChartPlaceholder(),
        SizedBox(height: 16),
        _RemainingSupplyRow(),
        SizedBox(height: 16),
        _CrewStatusSummary(),
        SizedBox(height: 16),
        _LogsCard(),
        SizedBox(height: 16),
        _StarredResources(),
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

class _ActiveAlertsPanel extends StatelessWidget {
  const _ActiveAlertsPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.target, size: 20),
                SizedBox(width: 8),
                Text('All systems nominal', style: TextStyle(color: AppColors.textSecondary)),
              ],
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

class _RemainingSupplyRow extends StatelessWidget {
  const _RemainingSupplyRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _SupplyCard(title: 'Food supply', remaining: '21D Remaining', urgent: false)),
        SizedBox(width: 16),
        Expanded(child: _SupplyCard(title: 'Water supply', remaining: '14D Remaining', urgent: true)),
      ],
    );
  }
}

class _SupplyCard extends StatelessWidget {
  const _SupplyCard({required this.title, required this.remaining, required this.urgent});

  final String title;
  final String remaining;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final color = urgent ? AppColors.warning : AppColors.target;
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(remaining, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

class _CrewStatusSummary extends StatelessWidget {
  const _CrewStatusSummary();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crew status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: const [
                _Avatar(initials: 'CM', color: AppColors.target),
                SizedBox(width: 8),
                _Avatar(initials: 'ME', color: AppColors.target),
                SizedBox(width: 8),
                _Avatar(initials: 'EN', color: AppColors.target),
                SizedBox(width: 8),
                _Avatar(initials: 'GE', color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 12),
            const Text('3 nominal, 1 on EVA', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.background,
      child: Text(initials, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _LogsCard extends StatelessWidget {
  const _LogsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            _logLine('08:12', 'Restock', 'Food supply +50', AppColors.target),
            _logLine('07:30', 'Consumption', 'Water -2.5', AppColors.textSecondary),
            _logLine('06:00', 'Status', 'Crew 3 on EVA', AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _logLine(String time, String type, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(time, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace')),
          const SizedBox(width: 12),
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Text('$type: $message', style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _StarredResources extends StatelessWidget {
  const _StarredResources();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Starred resources', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('Food'), backgroundColor: AppColors.background),
                Chip(label: Text('Water'), backgroundColor: AppColors.background),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
