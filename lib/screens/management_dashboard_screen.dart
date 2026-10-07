import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/item.dart';
import '../services/data_service.dart';

class ManagementDashboardScreen extends StatelessWidget {
  final User currentUser;

  const ManagementDashboardScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Management Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Items'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ItemsTab(),
            if (currentUser.role == UserRole.admin)
              _UsersTab()
            else
              const Center(child: Text('Only Admins can manage users.')),
          ],
        ),
      ),
    );
  }
}

class _ItemsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final items = dataService.items;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add New Item'),
            onPressed: () => _showAddItemDialog(context, dataService),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.category} - ${item.subcategory} | Qty: ${item.totalQuantity} | \$${item.pricePerDay}/day'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => dataService.removeItem(item.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context, DataService dataService) {
    final nameController = TextEditingController();
    final catController = TextEditingController();
    final subcatController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: catController, decoration: const InputDecoration(labelText: 'Category')),
                TextField(controller: subcatController, decoration: const InputDecoration(labelText: 'Subcategory')),
                TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'Total Quantity'), keyboardType: TextInputType.number),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price Per Day'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final qty = int.tryParse(qtyController.text) ?? 1;
                final price = double.tryParse(priceController.text) ?? 0.0;
                final newItem = Item(
                  id: 'i${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.isNotEmpty ? nameController.text : 'Unknown',
                  category: catController.text.isNotEmpty ? catController.text : 'Misc',
                  subcategory: subcatController.text,
                  totalQuantity: qty,
                  availableQuantity: qty,
                  pricePerDay: price,
                );
                dataService.addItem(newItem);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final users = dataService.users;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Add New User'),
            onPressed: () => _showAddUserDialog(context, dataService),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.role.name),
                trailing: DropdownButton<UserRole>(
                  value: user.role,
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.name),
                    );
                  }).toList(),
                  onChanged: (newRole) {
                    if (newRole != null) {
                      dataService.changeUserRole(user.id, newRole);
                    }
                  },
                ),
                leading: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => dataService.removeUser(user.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddUserDialog(BuildContext context, DataService dataService) {
    final nameController = TextEditingController();
    UserRole selectedRole = UserRole.customer;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 16),
                  DropdownButton<UserRole>(
                    isExpanded: true,
                    value: selectedRole,
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRole = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      dataService.addUser(nameController.text, selectedRole);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
