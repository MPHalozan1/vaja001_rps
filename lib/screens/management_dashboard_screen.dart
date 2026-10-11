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

    // We need to access the currentUser from the parent state.
    // An easy way is to grab it from the closest ManagementDashboardScreen context.
    final dashboard = context.findAncestorWidgetOfExactType<ManagementDashboardScreen>();
    final currentUser = dashboard!.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add New Item'),
            onPressed: () => _showAddItemDialog(context, dataService, currentUser),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No items in inventory.',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.category} - ${item.subcategory} | Qty: ${item.totalQuantity} | \$${item.pricePerDay}/day'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          try {
                            dataService.removeItem(currentUser, item.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed successfully.')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context, DataService dataService, User currentUser) {
    final nameController = TextEditingController();
    final catController = TextEditingController();
    final subcatController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add New Item', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: catController, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: subcatController, decoration: const InputDecoration(labelText: 'Subcategory', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'Total Quantity', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price Per Day', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final qty = int.tryParse(qtyController.text) ?? -1;
                        final price = double.tryParse(priceController.text) ?? -1.0;

                        if (qty < 0 || price < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Quantity and Price must be 0 or greater.'), backgroundColor: Colors.red));
                          return;
                        }

                        final newItem = Item(
                          id: 'i${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text.isNotEmpty ? nameController.text : 'Unknown',
                          category: catController.text.isNotEmpty ? catController.text : 'Misc',
                          subcategory: subcatController.text,
                          totalQuantity: qty,
                          availableQuantity: qty,
                          pricePerDay: price,
                        );

                        try {
                          dataService.addItem(currentUser, newItem);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added successfully.')));
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                        }
                      },
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
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

    final dashboard = context.findAncestorWidgetOfExactType<ManagementDashboardScreen>();
    final currentUser = dashboard!.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Add New User'),
            onPressed: () => _showAddUserDialog(context, dataService, currentUser),
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No users found.',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
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
                            try {
                              dataService.changeUserRole(currentUser, user.id, newRole);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User role updated successfully.')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                            }
                          }
                        },
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          try {
                            dataService.removeUser(currentUser, user.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User removed successfully.')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddUserDialog(BuildContext context, DataService dataService, User currentUser) {
    final nameController = TextEditingController();
    UserRole selectedRole = UserRole.customer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add New User', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    isExpanded: true,
                    initialValue: selectedRole,
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            try {
                              dataService.addUser(currentUser, nameController.text, selectedRole);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User added successfully.')));
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                            }
                          }
                        },
                        child: const Text('Add User'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
