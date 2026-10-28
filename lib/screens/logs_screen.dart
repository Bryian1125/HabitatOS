import 'package:flutter/material.dart';
import '../theme.dart';

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
        ...logs.map((entry) => InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(entry, style: const TextStyle(color: AppColors.textSecondary)),
          ),
        )),
      ],
    );
  }
}
