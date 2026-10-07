import 'package:flutter/material.dart';
import '../models/user.dart';
import 'management_dashboard_screen.dart';
import 'item_catalog_screen.dart';

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemCatalogScreen(currentUser: user),
                    ),
                  );
                },
                child: const Text('Item Catalog'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/customer_dashboard'),
                child: const Text('My Dashboard'),
              ),
            ],
            if (user.role == UserRole.admin || user.role == UserRole.employee) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManagementDashboardScreen(currentUser: user),
                    ),
                  );
                },
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
