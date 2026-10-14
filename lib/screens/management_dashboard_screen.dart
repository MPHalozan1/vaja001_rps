import '../models/borrow_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/item.dart';
import '../models/bill.dart';
import '../services/data_service.dart';
import '../widgets/notification_bell.dart';
import '../widgets/hover_scale_wrapper.dart';

class ManagementDashboardScreen extends StatelessWidget {
  final User currentUser;

  const ManagementDashboardScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          actions: [NotificationBell(currentUser: currentUser)],
          title: const Text('Management Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Items'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Rentals'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Analytics'),
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
            _RentalsTab(currentUser: currentUser),
            _AnalyticsTab(currentUser: currentUser),
            _MaintenanceTab(currentUser: currentUser),
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Item'),
                onPressed: () =>
                    _showAddItemBottomSheet(context, dataService, currentUser),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items in inventory.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
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
                          subtitle: Text(
                            '${item.category} - ${item.subcategory} | Qty: ${item.totalQuantity} | \$${item.pricePerDay}/day',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              try {
                                dataService.removeInventoryItem(
                                  currentUser,
                                  item.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item removed successfully.'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemBottomSheet(
    BuildContext context,
    DataService dataService,
    User currentUser,
  ) {
    final formKey = GlobalKey<FormState>();
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
            top: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add New Item',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          helperText: 'e.g., MacBook Pro 16"',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return dataService.categories;
                          }
                          return dataService.categories.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          catController.text = selection;
                        },
                        fieldViewBuilder:
                            (
                              context,
                              controller,
                              focusNode,
                              onEditingComplete,
                            ) {
                              controller.addListener(() {
                                catController.text = controller.text;
                              });
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: const InputDecoration(
                                  labelText: 'Category *',
                                  helperText: 'Select or type a new category',
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                              );
                            },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: subcatController,
                        decoration: const InputDecoration(
                          labelText: 'Subcategory *',
                          helperText: 'e.g., Laptops',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: qtyController,
                        decoration: const InputDecoration(
                          labelText: 'Total Quantity *',
                          helperText: 'Must be an integer >= 0',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (int.tryParse(v) == null || int.parse(v) < 0)
                            return 'Invalid quantity';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price Per Day *',
                          helperText: 'e.g., 50.00',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null || double.parse(v) < 0)
                            return 'Invalid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final qty = int.parse(qtyController.text);
                                final price = double.parse(
                                  priceController.text,
                                );

                                final newItem = Item(
                                  id: 'i${DateTime.now().millisecondsSinceEpoch}',
                                  name: nameController.text,
                                  category: catController.text,
                                  subcategory: subcatController.text,
                                  totalQuantity: qty,
                                  availableQuantity: qty,
                                  pricePerDay: price,
                                );

                                try {
                                  dataService.requestOrAddCategory(
                                    currentUser,
                                    catController.text,
                                  );
                                  dataService.addInventoryItem(
                                    currentUser,
                                    newItem,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item added successfully.'),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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
    // Admins manage users
    final usersList = dataService.users
        .where((u) => u.role != UserRole.admin)
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            if (dataService.pendingCategories.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Categories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: dataService.pendingCategories
                          .map(
                            (cat) => Chip(
                              label: Text(cat),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () =>
                                  dataService.rejectCategory(currentUser, cat),
                              avatar: IconButton(
                                icon: const Icon(Icons.check, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => dataService.approveCategory(
                                  currentUser,
                                  cat,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Add New Employee'),
                onPressed: () =>
                    _showAddUserBottomSheet(context, dataService, currentUser),
              ),
            ),
            Expanded(
              child: usersList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: usersList.length,
                      itemBuilder: (context, index) {
                        final user = usersList[index];
                        return ListTile(
                          title: Row(
                            children: [
                              Text(user.name),
                              if (user.strikes > 0) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.warning,
                                  color: user.strikes >= 3
                                      ? Colors.red
                                      : Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.strikes} Strikes',
                                  style: TextStyle(
                                    color: user.strikes >= 3
                                        ? Colors.red
                                        : Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              if (user.isSuspended) ...[
                                const SizedBox(width: 8),
                                const Chip(
                                  label: Text('SUSPENDED'),
                                  backgroundColor: Colors.red,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            '${user.role.name.toUpperCase()} ID: ${user.id}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.role == UserRole.customer)
                                TextButton(
                                  onPressed: () {
                                    try {
                                      dataService.toggleUserSuspension(
                                        currentUser,
                                        user.id,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    user.isSuspended ? 'Unsuspend' : 'Suspend',
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  try {
                                    dataService.deleteUserAccount(
                                      currentUser,
                                      user.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'User removed successfully.',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserBottomSheet(
    BuildContext context,
    DataService dataService,
    User currentUser,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

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
                top: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add New Employee',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            helperText: 'Full name of the new employee.',
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter a name.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  try {
                                    final parts = nameController.text.split(
                                      ' ',
                                    );
                                    final firstName = parts.first;
                                    final lastName = parts.length > 1
                                        ? parts.sublist(1).join(' ')
                                        : '';
                                    dataService.registerNewUser(
                                      currentUser,
                                      firstName,
                                      lastName,
                                      UserRole.employee,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Employee added successfully.',
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
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
              ),
            );
          },
        );
      },
    );
  }
}

class _RentalsTab extends StatefulWidget {
  final User currentUser;
  const _RentalsTab({required this.currentUser});

  @override
  State<_RentalsTab> createState() => _RentalsTabState();
}

class _RentalsTabState extends State<_RentalsTab> {
  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final rentals = dataService.borrowRequests
        .where((r) => !r.isReturned)
        .toList();

    // Sort so overdue are at the top
    rentals.sort((a, b) {
      final aOverdue = DateTime.now().isAfter(a.returnDate);
      final bOverdue = DateTime.now().isAfter(b.returnDate);
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;
      return a.returnDate.compareTo(b.returnDate);
    });

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            if (widget.currentUser.role == UserRole.employee)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Create Walk-In Ticket'),
                  onPressed: () => _showWalkInBottomSheet(
                    context,
                    dataService,
                    widget.currentUser,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  final req = rentals[index];
                  String customerName = 'Unknown';
                  try {
                    customerName = dataService.users
                        .firstWhere((u) => u.id == req.userId)
                        .name;
                  } catch (_) {}
                  String itemName = 'Unknown';
                  try {
                    itemName = dataService.items
                        .firstWhere((i) => i.id == req.itemId)
                        .name;
                  } catch (_) {}

                  final isOverdue = DateTime.now().isAfter(req.returnDate);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: isOverdue
                        ? Theme.of(
                            context,
                          ).colorScheme.errorContainer.withValues(alpha: 0.3)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isOverdue)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OVERDUE (ZAMUDA)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Text(
                            'Rental ID: ${req.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Customer: $customerName'),
                          Text('Item: $itemName'),
                          Text('Location: ${req.location}'),
                          Text(
                            'Return Date: ${req.returnDate.toString().split(' ')[0]}',
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonal(
                              onPressed: () =>
                                  _showReturnDialog(context, dataService, req),
                              child: const Text('Process Return'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnDialog(
    BuildContext context,
    DataService dataService,
    BorrowRequest req,
  ) {
    String selectedCondition = 'Good/Brezhibno';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Process Return'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select the condition of the item upon return:'),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text('Good / Brezhibno'),
                    value: 'Good/Brezhibno',
                    groupValue: selectedCondition,
                    onChanged: (val) =>
                        setState(() => selectedCondition = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Damaged / Poškodovano'),
                    value: 'Damaged/Poškodovano',
                    groupValue: selectedCondition,
                    onChanged: (val) =>
                        setState(() => selectedCondition = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    try {
                      dataService.processReturn(
                        widget.currentUser,
                        req.id,
                        selectedCondition == 'Damaged/Poškodovano',
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Return processed.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWalkInBottomSheet(
    BuildContext context,
    DataService dataService,
    User currentUser,
  ) {
    final formKey = GlobalKey<FormState>();
    User? selectedCustomer;
    Item? selectedItem;
    DateTimeRange? selectedDateRange;
    final locationController = TextEditingController(text: 'Skladišče');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final customers = dataService.users
                .where((u) => u.role == UserRole.customer)
                .toList();
            final items = dataService.items;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'New Walk-In Ticket',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<User>(
                            decoration: const InputDecoration(
                              labelText: 'Select Customer *',
                              helperText: 'The customer borrowing the item.',
                            ),
                            initialValue: selectedCustomer,
                            items: customers
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedCustomer = val),
                            validator: (v) =>
                                v == null ? 'Please select a customer.' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Item>(
                            decoration: const InputDecoration(
                              labelText: 'Select Item *',
                              helperText: 'The item being borrowed.',
                            ),
                            initialValue: selectedItem,
                            items: items
                                .map(
                                  (i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(i.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedItem = val),
                            validator: (v) =>
                                v == null ? 'Please select an item.' : null,
                          ),
                          const SizedBox(height: 16),
                          FormField<DateTimeRange>(
                            validator: (v) => selectedDateRange == null
                                ? 'Please select a date range.'
                                : null,
                            builder: (formFieldState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: formFieldState.hasError
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.error
                                            : Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    title: Text(
                                      selectedDateRange == null
                                          ? 'Select Dates *'
                                          : '${selectedDateRange!.start.toString().split(' ')[0]} - ${selectedDateRange!.end.toString().split(' ')[0]}',
                                    ),
                                    trailing: const Icon(Icons.date_range),
                                    onTap: () async {
                                      final now = DateTime.now();
                                      final picked = await showDateRangePicker(
                                        context: context,
                                        firstDate: now,
                                        lastDate: now.add(
                                          const Duration(days: 365),
                                        ),
                                        initialDateRange: selectedDateRange,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          selectedDateRange = picked;
                                          formFieldState.didChange(picked);
                                        });
                                      }
                                    },
                                  ),
                                  if (formFieldState.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        top: 8,
                                      ),
                                      child: Text(
                                        formFieldState.errorText!,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: 'Intended Location of Use *',
                              helperText: 'Where will you be using this item?',
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter a location.'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate() &&
                                      selectedDateRange != null) {
                                    try {
                                      dataService.createWalkInTicket(
                                        currentUser,
                                        selectedCustomer!.id,
                                        selectedItem!.id,
                                        selectedDateRange!.start,
                                        selectedDateRange!.end,
                                        location: locationController.text
                                            .trim(),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Ticket created & bill sent for approval.',
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final User currentUser;
  const _AnalyticsTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    if (currentUser.role != UserRole.admin) {
      return const Center(child: Text('Only Admins can view analytics.'));
    }

    final dataService = Provider.of<DataService>(context);
    final items = dataService.items;

    // Calculate ROI
    // Map item id -> revenue
    Map<String, double> itemRevenue = {};
    for (var bill in dataService.bills) {
      if (bill.status == BillStatus.paid && bill.borrowRequestId != null) {
        try {
          var req = dataService.borrowRequests.firstWhere(
            (r) => r.id == bill.borrowRequestId,
          );
          itemRevenue[req.itemId] =
              (itemRevenue[req.itemId] ?? 0) + bill.amount;
        } catch (_) {}
      }
    }

    // Calculate rental counts
    Map<String, int> itemRentalCounts = {};
    for (var req in dataService.borrowRequests) {
      itemRentalCounts[req.itemId] = (itemRentalCounts[req.itemId] ?? 0) + 1;
    }

    var itemsSortedByROI = List<Item>.from(items);
    itemsSortedByROI.sort((a, b) {
      double roiA =
          (itemRevenue[a.id] ?? 0) / (a.purchaseCost > 0 ? a.purchaseCost : 1);
      double roiB =
          (itemRevenue[b.id] ?? 0) / (b.purchaseCost > 0 ? b.purchaseCost : 1);
      return roiB.compareTo(roiA);
    });

    var itemsSortedByPopularity = List<Item>.from(items);
    itemsSortedByPopularity.sort((a, b) {
      int countA = itemRentalCounts[a.id] ?? 0;
      int countB = itemRentalCounts[b.id] ?? 0;
      return countB.compareTo(countA);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BUSINESS ANALYTICS',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'Return on Investment (ROI)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...itemsSortedByROI.take(5).map((item) {
                double revenue = itemRevenue[item.id] ?? 0;
                double cost = item.purchaseCost > 0 ? item.purchaseCost : 1;
                double roi = (revenue / cost) * 100;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: Text(item.name),
                    subtitle: Text(
                      'Revenue: \$${revenue.toStringAsFixed(2)} / Cost: \$${item.purchaseCost.toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      '${roi.toStringAsFixed(1)}% ROI',
                      style: TextStyle(
                        color: roi >= 100 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              Text(
                'Most Popular Items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...itemsSortedByPopularity.take(5).map((item) {
                int count = itemRentalCounts[item.id] ?? 0;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.star),
                    title: Text(item.name),
                    trailing: Text(
                      '$count Rentals',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaintenanceTab extends StatelessWidget {
  final User currentUser;
  const _MaintenanceTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final damagedItems = dataService.items.where((i) => i.isDamaged).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'MAINTENANCE QUEUE',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (damagedItems.isEmpty)
              const Expanded(
                child: Center(child: Text('No damaged items in the queue.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: damagedItems.length,
                  itemBuilder: (context, index) {
                    final item = damagedItems[index];
                    return HoverScaleWrapper(
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.build,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'ID: ${item.id} | Category: ${item.category}',
                          ),
                          trailing: FilledButton.tonal(
                            onPressed: () {
                              try {
                                dataService.repairItem(currentUser, item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Item marked as repaired and returned to Skladišče.',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('Mark as Repaired'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
