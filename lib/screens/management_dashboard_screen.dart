import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/item.dart';
import '../models/bill.dart';
import '../services/data_service.dart';

class ManagementDashboardScreen extends StatelessWidget {
  final User currentUser;

  const ManagementDashboardScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Management Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Items'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Bills'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ItemsTab(currentUser: currentUser),
            if (currentUser.role == UserRole.admin)
              _UsersTab(currentUser: currentUser)
            else
              const Center(child: Text('Only Admins can manage users.')),
            _BillsTab(currentUser: currentUser),
          ],
        ),
      ),
    );
  }
}


class _ItemsTab extends StatelessWidget {
  final User currentUser;

  const _ItemsTab({required this.currentUser});

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
            onPressed: () => _showAddItemBottomSheet(context, dataService, currentUser),
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
                          dataService.removeInventoryItem(currentUser, item.id);
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

  void _showAddItemBottomSheet(BuildContext context, DataService dataService, User currentUser) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final catController = TextEditingController();
    final subcatController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add New Item', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name *', helperText: 'e.g. Sony Camera'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: catController,
                    decoration: const InputDecoration(labelText: 'Category *', helperText: 'e.g. Photo & Video'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: subcatController,
                    decoration: const InputDecoration(labelText: 'Subcategory', helperText: 'e.g. Cameras'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Total Quantity *', helperText: 'Must be an integer > 0'),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Must be a valid integer' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price Per Day *', helperText: 'Enter price as 0.00'),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Must be a valid number' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final qty = int.parse(qtyController.text);
                            final price = double.parse(priceController.text);

                            if (qty < 0 || price < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Quantity and Price must be 0 or greater.'), backgroundColor: Colors.red));
                              return;
                            }

                            final newItem = Item(
                              id: 'i${DateTime.now().millisecondsSinceEpoch}',
                              name: nameController.text.trim(),
                              category: catController.text.trim(),
                              subcategory: subcatController.text.trim(),
                              totalQuantity: qty,
                              availableQuantity: qty,
                              pricePerDay: price,
                            );

                            try {
                              dataService.addInventoryItem(currentUser, newItem);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added successfully.')));
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                            }
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  final User currentUser;

  const _UsersTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    // Admins manage Employees now (not customers, but they can see them maybe. Actually, plan says "manage Employees")
    final employees = dataService.users.where((u) => u.role == UserRole.employee).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Add New Employee'),
            onPressed: () => _showAddUserBottomSheet(context, dataService, currentUser),
          ),
        ),
        Expanded(
          child: employees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No employees found.',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final user = employees[index];
                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text('Employee ID: ${user.id}'),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          try {
                            dataService.deleteUserAccount(currentUser, user.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee removed successfully.')));
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

  void _showAddUserBottomSheet(BuildContext context, DataService dataService, User currentUser) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Add New Employee', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name *', helperText: 'Full display name of employee'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        FilledButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              try {
                                dataService.registerNewUser(currentUser, nameController.text.trim(), UserRole.employee);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee added successfully.')));
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                              }
                            }
                          },
                          child: const Text('Add'),
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
      },
    );
  }
}

class _BillsTab extends StatelessWidget {
  final User currentUser;

  const _BillsTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final bills = dataService.bills;

    return Column(
      children: [
        if (currentUser.role == UserRole.employee)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Create Walk-In Ticket'),
              onPressed: () => _showWalkInBottomSheet(context, dataService, currentUser),
            ),
          ),
        Expanded(
          child: bills.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No bills found.',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    return ListTile(
                      title: Text('Bill ID: ${bill.id} - \$${bill.amount.toStringAsFixed(2)}'),
                      subtitle: Text('Status: ${bill.status.name}'),
                      trailing: bill.status == BillStatus.pendingAdminApproval
                          ? FilledButton.tonal(
                              onPressed: () {
                                try {
                                  final msg = dataService.approveEmployeeBill(currentUser, bill.id);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                                }
                              },
                              child: const Text('Approve'),
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showWalkInBottomSheet(BuildContext context, DataService dataService, User currentUser) {
    final formKey = GlobalKey<FormState>();
    User? selectedCustomer;
    Item? selectedItem;
    DateTimeRange? selectedDateRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final customers = dataService.users.where((u) => u.role == UserRole.customer).toList();
            final items = dataService.items;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('New Walk-In Ticket', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<User>(
                        decoration: const InputDecoration(labelText: 'Select Customer *'),
                        initialValue: selectedCustomer,
                        items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                        onChanged: (val) => setState(() => selectedCustomer = val),
                        validator: (v) => v == null ? 'Customer is required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Item>(
                        decoration: const InputDecoration(labelText: 'Select Item *'),
                        initialValue: selectedItem,
                        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i.name))).toList(),
                        onChanged: (val) => setState(() => selectedItem = val),
                        validator: (v) => v == null ? 'Item is required' : null,
                      ),
                      const SizedBox(height: 16),
                      FormField<DateTimeRange>(
                        validator: (v) => selectedDateRange == null ? 'Date range is required' : null,
                        builder: (FormFieldState<DateTimeRange> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: state.hasError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                title: Text(selectedDateRange == null ? 'Select Dates *' : '${selectedDateRange!.start.toString().split(' ')[0]} - ${selectedDateRange!.end.toString().split(' ')[0]}'),
                                trailing: const Icon(Icons.date_range),
                                onTap: () async {
                                  final now = DateTime.now();
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: now,
                                    lastDate: now.add(const Duration(days: 365)),
                                    initialDateRange: selectedDateRange,
                                  );
                                  if (picked != null) {
                                    setState(() => selectedDateRange = picked);
                                    state.didChange(picked);
                                  }
                                },
                              ),
                              if (state.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 16),
                                  child: Text(state.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                                ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          FilledButton(
                            onPressed: () {
                              if (formKey.currentState!.validate() && selectedDateRange != null) {
                                try {
                                  dataService.createWalkInTicket(
                                    currentUser,
                                    selectedCustomer!.id,
                                    selectedItem!.id,
                                    selectedDateRange!.start,
                                    selectedDateRange!.end,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket created & bill sent for approval.')));
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                                }
                              }
                            },
                            child: const Text('Create'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
