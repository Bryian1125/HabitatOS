import 'package:flutter/material.dart';
import '../theme.dart';

class Resource {
  final String id;
  final String name;
  final int remainingDays;
  final double capacity; // percentage
  final int quantity;
  final String unit;

  Resource({
    required this.id,
    required this.name,
    required this.remainingDays,
    required this.capacity,
    required this.quantity,
    required this.unit,
  });
}

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final List<Resource> _resources = [];

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _resources.add(Resource(
      id: 'food_1',
      name: 'Food',
      remainingDays: 31,
      capacity: 44.0,
      quantity: 0,
      unit: 'kg',
    ));
    _resources.add(Resource(
      id: 'water_1',
      name: 'Water',
      remainingDays: 28,
      capacity: 38.0,
      quantity: 0,
      unit: 'L',
    ));
  }

  void _addResource() {
    showDialog(
      context: context,
      builder: (context) => _ResourceDialog(
        onSave: (name, quantity, unit) {
          setState(() {
            _resources.add(Resource(
              id: 'new_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              remainingDays: 0,
              capacity: 0.0,
              quantity: quantity,
              unit: unit,
            ));
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _editResource(Resource resource) {
    showDialog(
      context: context,
      builder: (context) => _ResourceDialog(
        initialName: resource.name,
        initialQuantity: resource.quantity,
        initialUnit: resource.unit,
        onSave: (name, quantity, unit) {
          setState(() {
            final index = _resources.indexWhere((r) => r.id == resource.id);
            if (index != -1) {
              _resources[index] = Resource(
                id: resource.id,
                name: name,
                remainingDays: 0,
                capacity: 0.0,
                quantity: quantity,
                unit: unit,
              );
            }
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deleteResource(Resource resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Are you sure you want to delete "${resource.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _resources.removeWhere((r) => r.id == resource.id);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
        ..._resources.map((resource) => Card(
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
                          resource.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editResource(resource),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _deleteResource(resource),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'chart placeholder',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ))
      ],
    );
  }
}

class _ResourceDialog extends StatefulWidget {
  final String? initialName;
  final int? initialQuantity;
  final String? initialUnit;
  final void Function(String, int, String) onSave;

  const _ResourceDialog({
    Key? key,
    this.initialName,
    this.initialQuantity,
    this.initialUnit,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_ResourceDialog> createState() => _ResourceDialogState();
}

class _ResourceDialogState extends State<_ResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _quantityController = TextEditingController(text: widget.initialQuantity?.toString() ?? '');
  late final _unitController = TextEditingController(text: widget.initialUnit ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resource'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Resource Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final quantity = int.tryParse(_quantityController.text) ?? 0;
                  final unit = _unitController.text;
                  widget.onSave(_nameController.text, quantity, unit);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}