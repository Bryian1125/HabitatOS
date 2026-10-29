import 'package:flutter/material.dart';
import 'dart:async';

import '../models/log_entry.dart';
import '../services/storage.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'home_screen.dart';
import 'resources_screen.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = StorageService();
  int _selectedIndex = 0;
  final List<LogEntry> _resourceLogs = [];
  final List<Resource> _resources = [];
  bool _loaded = false;
  int _graphLineColor = 0xFF39FF14; // electric-neon-green

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hadStoredData = await _storage.hasData();
    final data = await _storage.load();
    if (!mounted) return;

    setState(() {
      _resources
        ..clear()
        ..addAll(hadStoredData ? data.resources : _seedResources());
      _resourceLogs
        ..clear()
        ..addAll(data.logs);
      _graphLineColor = data.graphLineColor;
      _loaded = true;
    });

    if (!hadStoredData) await _save();
  }

  /// Starting stock for a brand new install.
  List<Resource> _seedResources() => [
        Resource.create(
          id: 'food_1',
          name: 'Food',
          unit: 'kg',
          initialQuantity: 100,
        ),
        Resource.create(
          id: 'water_1',
          name: 'Water',
          unit: 'L',
          initialQuantity: 100,
        ),
      ];

  Future<void> _save() => _storage.save(
        HabitatData(
          resources: _resources,
          logs: _resourceLogs,
          graphLineColor: _graphLineColor,
        ),
      );

  void _persist() => unawaited(_save());

  List<Widget> get _pages => [
    HomeScreen(
      logs: _resourceLogs,
      resources: _resources,
      graphLineColor: _graphLineColor,
    ),
    ResourcesScreen(
      resources: _resources,
      onAdd: _addResource,
      onLog: _applyStockChange,
      onDelete: _deleteResource,
      onEdit: _editResource,
      graphLineColor: _graphLineColor,
    ),
    LogsScreen(
      logs: _resourceLogs,
      onDeleteLog: _deleteLog,
      onClearLogs: _clearLogs,
    ),
    SettingsScreen(
      onDeleteAllData: _deleteAllData,
      onGraphLineColorChanged: (color) => setState(() {
        _graphLineColor = color;
        _persist();
      }),
      currentGraphLineColor: _graphLineColor,
    ),
  ];

  void _deleteAllData() {
    setState(() {
      _resources.clear();
      _resourceLogs.clear();
    });
    _persist();
  }

  void _addResource(Resource resource) {
    setState(() => _resources.add(resource));
    _persist();
  }

  void _applyStockChange(String id, StockEntry entry, LogEntry log) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final previous = _resources[index];
    setState(() {
      _resources[index] = previous.withEntry(entry);
      _resourceLogs.add(log);
    });
    _persist();

    // Show custom toast with undo action
    _showUndoToast(log.message, previous, log);
  }

  void _showUndoToast(String message, Resource previous, LogEntry log) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    Timer? dismissTimer;

    entry = OverlayEntry(
      builder: (context) => _UndoToastWidget(
        message: message,
        onUndo: () {
          dismissTimer?.cancel();
          _revertStockChange(previous, log);
          entry.remove();
        },
        onDismiss: () {
          dismissTimer?.cancel();
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 3 seconds
    dismissTimer = Timer(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  void _revertStockChange(Resource previous, LogEntry log) {
    setState(() {
      final index = _resources.indexWhere((r) => r.id == previous.id);
      if (index != -1) _resources[index] = previous;
      _resourceLogs.remove(log);
    });
    _persist();
  }

  void _renameResource(String id, String name, String unit) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;
    setState(() {
      _resources[index] = _resources[index].withDetails(name: name, unit: unit);
    });
    _persist();
  }

  void _editResource(Resource resource) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditResourceDetailsDialog(
        resource: resource,
        onSave: (name, unit) => _renameResource(resource.id, name, unit),
        onDelete: () => _deleteResource(resource.id),
      ),
    );
  }

  void _deleteResource(String id) {
    setState(() {
      _resources.removeWhere((r) => r.id == id);
      _resourceLogs.removeWhere((log) => log.resourceId == id);
    });
    _persist();
  }

  void _deleteLog(LogEntry entry) {
    setState(() => _resourceLogs.remove(entry));
    _persist();
  }

  void _clearLogs() {
    setState(() => _resourceLogs.clear());
    _persist();
  }

  final List<String> _navLabels = const [
    'Home',
    'Resources',
    'Logs',
    'Settings',
  ];

  final List<IconData> _navIcons = const [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.receipt_long_outlined,
    Icons.settings_outlined,
  ];

  /// The full sidebar needs room for its labels; below this width it collapses
  /// to an icon rail so the content area keeps a usable size.
  static const _fullSidebarBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= _fullSidebarBreakpoint;
        return Row(
          children: [
            _buildSidePanel(expanded: expanded),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: _loaded
                    ? IndexedStack(index: _selectedIndex, children: _pages)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidePanel({required bool expanded}) {
    return Container(
      width: expanded ? 240 : 72,
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment:
            expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: expanded
                ? const EdgeInsets.fromLTRB(24, 32, 24, 8)
                : const EdgeInsets.fromLTRB(8, 32, 8, 8),
            child: expanded
                ? const Text(
                    'HabitatOS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.eco_outlined,
                    color: AppColors.textPrimary, size: 26),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _navLabels.length,
              itemBuilder: (context, index) {
                final selected = index == _selectedIndex;
                final color =
                    selected ? AppColors.accent : AppColors.textSecondary;
                final icon = Icon(
                  _navIcons[index],
                  size: 20,
                  color: color,
                );
                return InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: expanded ? 24 : 0,
                      vertical: 12,
                    ),
                    child: expanded
                        ? Row(
                            children: [
                              icon,
                              const SizedBox(width: 12),
                              Text(
                                _navLabels[index],
                                style: TextStyle(
                                  color: color,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          )
                        : Tooltip(
                            message: _navLabels[index],
                            child: Center(child: icon),
                          ),
                  ),
                );
              },
            ),
          ),
          if (expanded)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: _SidePanelClock(),
            ),
        ],
      ),
    );
  }
}

class _SidePanelClock extends StatefulWidget {
  const _SidePanelClock();

  @override
  State<_SidePanelClock> createState() => _SidePanelClockState();
}

class _SidePanelClockState extends State<_SidePanelClock> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'DMY:${two(now.day)}.${two(now.month)}.${now.year}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
/// Toast widget with undo action for stock changes
class _UndoToastWidget extends StatefulWidget {
  const _UndoToastWidget({
    required this.message,
    required this.onUndo,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;

  @override
  State<_UndoToastWidget> createState() => _UndoToastWidgetState();
}

class _UndoToastWidgetState extends State<_UndoToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    key: const Key('undo_toast_button'),
                    onPressed: () {
                      widget.onUndo();
                      _dismiss();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('UNDO'),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for editing resource details (rename + delete)
class _EditResourceDetailsDialog extends StatefulWidget {
  const _EditResourceDetailsDialog({
    required this.resource,
    required this.onSave,
    required this.onDelete,
  });

  final Resource resource;
  final void Function(String name, String unit) onSave;
  final VoidCallback onDelete;

  @override
  State<_EditResourceDetailsDialog> createState() =>
      _EditResourceDetailsDialogState();
}

class _EditResourceDetailsDialogState extends State<_EditResourceDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.resource.name);
  late final TextEditingController _unit =
      TextEditingController(text: widget.resource.unit);

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_name.text.trim(), _unit.text.trim());
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (!await _confirmDelete(context) || !mounted) return;
    widget.onDelete();
    Navigator.of(context).pop();
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Delete Resource',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete this resource? Its log entries '
          'will be deleted too.',
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
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text(
        'Edit Resource',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      insetPadding: const EdgeInsets.all(20),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Resource Name'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unit,
              decoration: const InputDecoration(labelText: 'Unit'),
              validator: _required,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cancel, color: AppColors.textSecondary),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: AppColors.critical),
          tooltip: 'Delete',
          onPressed: _delete,
        ),
        IconButton(
          icon: const Icon(Icons.save, color: AppColors.accent),
          tooltip: 'Save',
          onPressed: _submit,
        ),
      ],
    );
  }
}
