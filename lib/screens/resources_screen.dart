import 'package:flutter/material.dart';

import '../gradient_border.dart';
import '../models/log_entry.dart';
import '../models/resource.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/stock_chart.dart';

export '../models/resource.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({
    super.key,
    required this.resources,
    required this.onAdd,
    required this.onLog,
    required this.onDelete,
    required this.onEdit,
    required this.graphLineColor,
  });

  final List<Resource> resources;
  final void Function(Resource) onAdd;
  final void Function(String id, StockEntry entry, LogEntry log) onLog;
  final void Function(String id) onDelete;
  final void Function(Resource) onEdit;
  final int graphLineColor;

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _addResource() {
    showDialog<void>(
      context: context,
      builder: (_) => _AddResourceDialog(
        onSave: (name, quantity, unit) => widget.onAdd(
          Resource.create(
            id: 'resource_${DateTime.now().microsecondsSinceEpoch}',
            name: name,
            unit: unit,
            initialQuantity: quantity,
          ),
        ),
      ),
    );
  }

  void _editResource(Resource resource) {
    showDialog<void>(
      context: context,
      builder: (_) => _LogStockDialog(
        resource: resource,
        onSave: (delta, info, time) =>
            _logStockChange(resource.id, delta, info, time),
        onDelete: () => widget.onDelete(resource.id),
      ),
    );
  }

  void _editResourceDetails(Resource resource) {
    widget.onEdit(resource);
  }

  void _logStockChange(String id, int delta, String info, DateTime time) {
    final index = widget.resources.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final resource = widget.resources[index];
    final note = info.isEmpty ? '' : ', $info';
    final log = LogEntry(
      time: time,
      resourceId: id,
      message:
          'Edit ${resource.name}: ${signedDelta(delta)} ${resource.unit}$note',
    );

    widget.onLog(id, StockEntry(time, delta, info), log);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Resources',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.card,
            foregroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _addResource,
          child: const Text('Add Resource'),
        ),
        const SizedBox(height: 16),
        ...widget.resources.map(
          (resource) => _ResourceCard(
            key: ValueKey(resource.id),
            resource: resource,
            onEdit: () => _editResource(resource),
            onEditDetails: () => _editResourceDetails(resource),
            graphLineColor: widget.graphLineColor,
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    super.key,
    required this.resource,
    required this.onEdit,
    required this.onEditDetails,
    required this.graphLineColor,
  });

  final Resource resource;
  final VoidCallback onEdit;
  final VoidCallback onEditDetails;
  final int graphLineColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientBorder(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${resource.name.toUpperCase()} (${resource.unit})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        tooltip: 'Log stock change',
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        tooltip: 'Edit resource',
                        onPressed: onEditDetails,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${resource.quantity} ${resource.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (resource.avgPerDay case final avg?)
                Text(
                  'AVG: ${avg.toStringAsFixed(1)} ${resource.unit}/d',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                width: double.infinity,
                child: StockChart(
                  resource: resource,
                  lineColor: graphLineColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AddResourceDialog extends StatefulWidget {
  const _AddResourceDialog({required this.onSave});

  final void Function(String name, int quantity, String unit) onSave;

  @override
  State<_AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<_AddResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unit.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _validateQuantity(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null) return 'Enter a whole number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      _name.text.trim(),
      int.parse(_quantity.text.trim()),
      _unit.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text(
        'Add Resource',
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
              controller: _quantity,
              decoration: const InputDecoration(labelText: 'Initial Quantity'),
              keyboardType: TextInputType.number,
              validator: _validateQuantity,
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
          icon: const Icon(Icons.add_circle, color: AppColors.accent),
          tooltip: 'Create',
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _LogStockDialog extends StatefulWidget {
  const _LogStockDialog({
    required this.resource,
    required this.onSave,
    required this.onDelete,
  });

  final Resource resource;
  final void Function(int delta, String info, DateTime time) onSave;
  final VoidCallback onDelete;

  @override
  State<_LogStockDialog> createState() => _LogStockDialogState();
}

class _LogStockDialogState extends State<_LogStockDialog> {
  final _delta = TextEditingController();
  final _info = TextEditingController();
  DateTime _dateTime = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _delta.dispose();
    _info.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    final delta = int.tryParse(_delta.text.trim());
    if (delta == null || delta == 0) {
      setState(() => _error = 'Enter a non-zero whole number');
      return;
    }
    if (widget.resource.wouldGoNegative(StockEntry(_dateTime, delta))) {
      setState(() => _error = 'Stock cannot go below zero');
      return;
    }
    widget.onSave(delta, _info.text.trim(), _dateTime);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (!await _confirmDelete(context) || !mounted) return;
    widget.onDelete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(
        '${resource.name.toUpperCase()} (${resource.unit})',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      insetPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current: ${resource.quantity} ${resource.unit}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _delta,
            decoration: InputDecoration(
              labelText: 'Quantity Change (- / +)',
              errorText: _error,
            ),
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _info,
            decoration: const InputDecoration(labelText: 'Info (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDateTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date / Time',
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.accent),
              ),
              child: Text(
                formatDateTime(_dateTime),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
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
          tooltip: 'Log',
          onPressed: _submit,
        ),
      ],
    );
  }
}

Future<bool> _confirmDelete(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text(
        'Confirm Delete',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: const Text(
        'Are you sure you want to delete this resource? Its log entries will '
        'be deleted too.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete', style: TextStyle(color: AppColors.critical)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
