import 'package:flutter/material.dart';

import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.onDeleteAllData,
    required this.onGraphLineColorChanged,
    required this.currentGraphLineColor,
  });

  final VoidCallback onDeleteAllData;
  final void Function(int color) onGraphLineColorChanged;
  final int currentGraphLineColor;

  // Preset colors for the graph line
  static const _presetColors = [
    0xFF39FF14, // electric-neon-green (default)
    0xFFCCCCCC, // accent grey
    0xFF00FFFF, // cyan
    0xFFFF3366, // pink
    0xFFFFCC00, // amber
    0xFF8844FF, // purple
    0xFF00FF88, // mint
    0xFFFF5500, // orange
  ];

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Delete All Data',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This removes every resource, stock change and log entry from this '
          'device. It cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
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
          'APPEARANCE',
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Graph Line Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _presetColors.map((color) {
                    final isSelected = color == currentGraphLineColor;
                    return InkWell(
                      onTap: () => onGraphLineColorChanged(color),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.border,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Color(color).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
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
