import 'billing_dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'item_catalog_screen.dart';
import 'customer_dashboard_screen.dart';
import 'management_dashboard_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final User user;

  const MainMenuScreen({super.key, required this.user});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;

  List<Widget> _getDestinations() {
    if (widget.user.role == UserRole.customer) {
      return [
        ItemCatalogScreen(currentUser: widget.user),
        CustomerDashboardScreen(currentUser: widget.user),
      ];
    } else {
      return [
        ManagementDashboardScreen(currentUser: widget.user),
        ItemCatalogScreen(currentUser: widget.user),
        BillingDashboardScreen(currentUser: widget.user),
      ];
    }
  }

  List<NavigationDestination> _getNavDestinations() {
    if (widget.user.role == UserRole.customer) {
      return const [
        NavigationDestination(icon: Icon(Icons.store), label: 'Catalog'),
        NavigationDestination(icon: Icon(Icons.person), label: 'My Dashboard'),
      ];
    } else {
      return const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Management'),
        NavigationDestination(icon: Icon(Icons.store), label: 'Catalog'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Billing'),
      ];
    }
  }

  List<NavigationRailDestination> _getRailDestinations() {
    if (widget.user.role == UserRole.customer) {
      return const [
        NavigationRailDestination(
          icon: Icon(Icons.store),
          label: Text('Catalog'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('My Dashboard'),
        ),
      ];
    } else {
      return const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Management'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.store),
          label: Text('Catalog'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long),
          label: Text('Billing'),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _getRailDestinations(),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/'),
                    ),
                  ),
                ),
              ),
            ),
          if (isWide) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _getDestinations()[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _getNavDestinations(),
            ),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton(
              mini: true,
              child: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
    );
  }
}
