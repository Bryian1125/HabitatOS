import 'package:flutter/material.dart';

import '../gradient_border.dart';
import '../models/log_entry.dart';
import '../theme.dart';
import '../utils/format.dart';

class LogsScreen extends StatelessWidget {
  final List<LogEntry> logs;
  const LogsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Logs',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ...logs.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GradientBorder(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10.5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      Text(entry.message,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(formatDateTime(entry.time),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 10)),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
