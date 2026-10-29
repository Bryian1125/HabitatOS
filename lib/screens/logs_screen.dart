import 'package:flutter/material.dart';

import '../gradient_border.dart';
import '../models/log_entry.dart';
import '../theme.dart';
import '../utils/format.dart';

class LogsScreen extends StatelessWidget {
  final List<LogEntry> logs;
  final void Function(LogEntry entry) onDeleteLog;
  final VoidCallback onClearLogs;

  const LogsScreen({
    super.key,
    required this.logs,
    required this.onDeleteLog,
    required this.onClearLogs,
  });

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Clear All Logs',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Delete every log entry? Resources and their stock history are kept.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear',
                style: TextStyle(color: AppColors.critical)),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onClearLogs();
  }

  @override
  Widget build(BuildContext context) {
    // Newest first, matching the home screen preview.
    final entries = logs.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(context);

        final entry = entries[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GradientBorder(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          entry.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatDateTime(entry.time),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.textSecondary),
                    tooltip: 'Delete entry',
                    onPressed: () => onDeleteLog(entry),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Text(
            'Logs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: logs.isEmpty ? null : () => _confirmClear(context),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
