import 'package:flutter/material.dart';
import '../theme.dart';
import '../gradient_border.dart';

class LogsScreen extends StatelessWidget {
  final List<String> logs;
  const LogsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Logs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        SizedBox(height: 16),
        ...logs.map((entry) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            
          ),
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Builder(builder: (context) {
            final parts = entry.split(': ');
            final info = parts.isNotEmpty ? parts.first : entry;
            final msg = parts.length > 1 ? parts.skip(1).join(': ') : '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text('"${msg.isNotEmpty ? msg : entry}"', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(info, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 4),
              ],
            );
          }),
        ))),
      ],
    );
  }
}
