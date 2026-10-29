import 'package:flutter/material.dart';
import 'theme.dart';

class GradientBorder extends StatelessWidget {
  final Widget child;
  const GradientBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.grey.shade600, const Color(0xFF333333)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.5),
        ),
        child: child,
      ),
    );
  }
}
