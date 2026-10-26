import 'package:flutter/material.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Empty panels — data will go here after CRUD setup
        _DataPanel(
          title: 'Food supply 14D',
          subtitle: 'warning: below optimal consumption line!',
          child: const Center(
            child: Text('chart placeholder', style: TextStyle(color: AppColors.textSecondary)),
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
                    children: const [
                      Text('LOGS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 12),
                      Divider(color: AppColors.border),
                      SizedBox(height: 8),
                      Divider(color: AppColors.border),
                      SizedBox(height: 8),
                      Divider(color: AppColors.border),
                      SizedBox(height: 8),
                      Divider(color: AppColors.border),
                      SizedBox(height: 8),
                      Divider(color: AppColors.border),
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