import 'package:flutter/material.dart';
import '../theme.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Resources', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        SizedBox(height: 16),
        Text('Manage habitat resources here.', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
