import 'package:flutter/material.dart';
import '../models/user.dart';

class MainMenuScreen extends StatelessWidget {
  final User user;

  const MainMenuScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Menu - ${user.role.name}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.name}'),
            const SizedBox(height: 20),
            if (user.role == UserRole.customer) ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/catalog'),
                child: const Text('Item Catalog'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/customer_dashboard'),
                child: const Text('My Dashboard'),
              ),
            ],
            if (user.role == UserRole.admin || user.role == UserRole.employee) ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/management_dashboard'),
                child: const Text('Management Dashboard'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
