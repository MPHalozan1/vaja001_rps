import 'package:flutter/material.dart';

class ManagementDashboardScreen extends StatelessWidget {
  const ManagementDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Management Dashboard')),
      body: const Center(child: Text('Management Dashboard Screen')),
    );
  }
}
