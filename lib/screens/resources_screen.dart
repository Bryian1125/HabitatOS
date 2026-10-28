import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// A single stock change (positive = added, negative = used) at a point in time.
@immutable
class StockEntry {
  const StockEntry(this.time, this.delta);

  final DateTime time;
  final int delta;
}

/// The stock level right after an entry was applied.
@immutable
class StockPoint {
  const StockPoint(this.time, this.quantity);

  final DateTime time;
  final int quantity;
}

/// A tracked resource. The quantity and the chart history are both derived
/// from [entries], so they can never disagree with each other, and entries
/// logged with a past date land at the right place in time.
@immutable
class Resource {
  Resource({
    required this.id,
    required this.name,
    required this.unit,
    required Iterable<StockEntry> entries,
  }) : entries = List.unmodifiable(_chronological(entries));

  /// Creates a resource whose first entry is its initial stock.
  factory Resource.create({
    required String id,
    required String name,
    required String unit,
    required int initialQuantity,
    DateTime? createdAt,
  }) {
    return Resource(
      id: id,
      name: name,
      unit: unit,
      entries: [StockEntry(createdAt ?? DateTime.now(), initialQuantity)],
    );
  }

  final String id;
  final String name;
  final String unit;

  /// Sorted oldest to newest.
  final List<StockEntry> entries;

  int get quantity => entries.fold(0, (sum, e) => sum + e.delta);

  /// Running stock level after each entry, oldest to newest.
  List<StockPoint> get timeline {
    var total = 0;
    return [for (final e in entries) StockPoint(e.time, total += e.delta)];
  }

  Resource withEntry(StockEntry entry) => Resource(
        id: id,
        name: name,
        unit: unit,
        entries: [...entries, entry],
      );

  /// True if logging [entry] would push the stock below zero at any moment.
  bool wouldGoNegative(StockEntry entry) =>
      withEntry(entry).timeline.any((p) => p.quantity < 0);

  static List<StockEntry> _chronological(Iterable<StockEntry> entries) {
    // Ties: apply additions before removals so same-time edits can't dip below zero.
    return entries.toList()
      ..sort((a, b) {
        final byTime = a.time.compareTo(b.time);
        return byTime != 0 ? byTime : b.delta.compareTo(a.delta);
      });
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key, required this.onEditLog});

  final void Function(String) onEditLog;

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  late final List<Resource> _resources = [
    Resource.create(id: 'food_1', name: 'Food', unit: 'kg', initialQuantity: 100),
    Resource.create(id: 'water_1', name: 'Water', unit: 'L', initialQuantity: 100),
  ];

  void _addResource() {
    showDialog<void>(
      context: context,
      builder: (_) => _AddResourceDialog(
        onSave: (name, quantity, unit) => setState(() {
          _resources.add(Resource.create(
            id: 'resource_${DateTime.now().microsecondsSinceEpoch}',
            name: name,
            unit: unit,
            initialQuantity: quantity,
          ));
        }),
      ),
    );
  }

  void _editResource(Resource resource) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditResourceDialog(
        resource: resource,
        onSave: (delta, info, time) =>
            _logStockChange(resource.id, delta, info, time),
        onDelete: () =>
            setState(() => _resources.removeWhere((r) => r.id == resource.id)),
      ),
    );
  }

  void _logStockChange(String id, int delta, String info, DateTime time) {
    final index = _resources.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final resource = _resources[index];
    setState(() {
      _resources[index] = resource.withEntry(StockEntry(time, delta));
    });

    final note = info.isEmpty ? '' : ', $info';
    widget.onEditLog(
      '${_formatDateTime(time)}: Edit ${resource.name}: '
      '${_signed(delta)} ${resource.unit}$note',
    );
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: _addResource,
          child: const Text('Add Resource'),
        ),
        const SizedBox(height: 16),
        for (final resource in _resources)
          _ResourceCard(
            key: ValueKey(resource.id),
            resource: resource,
            onEdit: () => _editResource(resource),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Resource card + chart
// ---------------------------------------------------------------------------

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({super.key, required this.resource, required this.onEdit});

  final Resource resource;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 16),
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
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: AppColors.accent),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${resource.quantity} ${resource.unit}',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: _StockChart(resource: resource),
            ),
          ],
        ),
      ),
    );
  }
}

/// Line chart of stock level over time.
///
/// The x-axis is real elapsed time (in hours since the first entry), so a gap
/// of a week looks seven times wider than a gap of a day. The line is extended
/// flat up to "now" because the stock level holds until the next change.
class _StockChart extends StatelessWidget {
  const _StockChart({required this.resource});

  final Resource resource;

  static const _yDivisions = 4;
  static const _xDivisions = 3;
  static const _msPerHour = Duration.millisecondsPerHour;

  /// Keeps the x-range non-zero when everything happened at the same instant.
  static const _minSpanHours = 1 / 60;

  static const _axisStyle = TextStyle(fontSize: 10, color: AppColors.textSecondary);

  @override
  Widget build(BuildContext context) {
    final timeline = resource.timeline;
    if (timeline.isEmpty) {
      return const Center(
        child: Text('No history yet', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final origin = timeline.first.time;
    double xOf(DateTime t) => t.difference(origin).inMilliseconds / _msPerHour;
    DateTime timeAt(double x) =>
        origin.add(Duration(milliseconds: (x * _msPerHour).round()));

    final spots = [
      for (final p in timeline) FlSpot(xOf(p.time), p.quantity.toDouble()),
    ];

    // Carry the current level forward to now.
    final nowX = xOf(DateTime.now());
    final hasTail = nowX > spots.last.x;
    if (hasTail) spots.add(FlSpot(nowX, spots.last.y));

    final tailX = spots.last.x;
    final maxX = max(tailX, _minSpanHours);
    final showClockTime = maxX < 24; // short span: HH:mm, otherwise MM-dd

    // Whole-number y ticks with a little headroom above the peak.
    final peak = timeline.fold<int>(1, (m, p) => max(m, p.quantity));
    final yInterval = (peak / _yDivisions).ceil();
    final maxY = (yInterval * _yDivisions).toDouble();

    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: AppColors.accent,
              dotData: FlDotData(
                show: true,
                // Mark real log entries only, not the synthetic "now" end point.
                checkToShowDot: (spot, _) => !(hasTail && spot.x == tailX),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval.toDouble(),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: yInterval.toDouble(),
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString(), style: _axisStyle),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: maxX / _xDivisions,
                getTitlesWidget: (value, meta) {
                  final t = timeAt(value);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      showClockTime ? _formatTime(t) : _formatDate(t),
                      style: _axisStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => [
                for (final spot in touched)
                  LineTooltipItem(
                    '${_formatDateTime(timeAt(spot.x))}\n${spot.y.toInt()} ${resource.unit}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------------

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

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

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
      title: const Text('Add Resource', style: TextStyle(color: AppColors.textPrimary)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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

class _EditResourceDialog extends StatefulWidget {
  const _EditResourceDialog({
    required this.resource,
    required this.onSave,
    required this.onDelete,
  });

  final Resource resource;
  final void Function(int delta, String info, DateTime time) onSave;
  final VoidCallback onDelete;

  @override
  State<_EditResourceDialog> createState() => _EditResourceDialogState();
}

class _EditResourceDialogState extends State<_EditResourceDialog> {
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
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _formatDateTime(_dateTime),
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
          icon: const Icon(Icons.delete, color: Colors.red),
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
      title: const Text('Confirm Delete', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text(
        'Are you sure you want to delete this resource?',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

String _two(int n) => n.toString().padLeft(2, '0');

String _formatDate(DateTime t) => '${_two(t.month)}-${_two(t.day)}';

String _formatTime(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

String _formatDateTime(DateTime t) => '${t.year}-${_formatDate(t)} ${_formatTime(t)}';

String _signed(int n) => n > 0 ? '+$n' : '$n';
