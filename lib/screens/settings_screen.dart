import 'package:flutter/material.dart';

import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onDeleteAllData});

  final VoidCallback onDeleteAllData;

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This removes every resource, stock change and log entry from this '
          'device. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.critical)),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onDeleteAllData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'DATA',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.delete_forever,
                color: AppColors.critical),
            title: const Text(
              'Delete all data',
              style: TextStyle(color: AppColors.critical),
            ),
            subtitle: const Text(
              'Removes every resource and log entry stored on this device.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            onTap: () => _confirmDeleteAll(context),
          ),
        ),
      ],
    );
  }
}
