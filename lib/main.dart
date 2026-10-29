import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitatOS',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: DashboardScreen(),
      ),
    );
  }
}