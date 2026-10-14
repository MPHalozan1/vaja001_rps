import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final User currentUser;

  const CustomerDashboardScreen({super.key, required this.currentUser});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.currentUser.firstName);
    _lastNameController = TextEditingController(text: widget.currentUser.lastName);
    _phoneController = TextEditingController(text: widget.currentUser.phoneNumber);
    _addressController = TextEditingController(text: widget.currentUser.address);
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    // Find up-to-date user info
    final upToDateUser = dataService.users.firstWhere((u) => u.id == widget.currentUser.id, orElse: () => widget.currentUser);

    final userRequests = dataService.borrowRequests.where((r) => r.userId == upToDateUser.id).toList();
    final userBills = dataService.bills.where((b) => b.customerId == upToDateUser.id).toList();

    double totalSpent = 0;
    for (var b in userBills) {
      totalSpent += b.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Row
                Row(
                  children: [
                    _buildStatCard(context, 'Active Rentals', userRequests.length.toString(), Icons.inventory_2),
                    const SizedBox(width: 16),
                    _buildStatCard(context, 'Total Spent', '\$${totalSpent.toStringAsFixed(2)}', Icons.attach_money),
                  ],
                ),
                const SizedBox(height: 32),

                // Profile Settings
                Text('PROFILE SETTINGS', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your first name.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your last name.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number *',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Phone number is required.';
                                if (double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) == null) {
                                  return 'Please enter a valid numeric phone number.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address *',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your address.' : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    dataService.updateUserProfile(
                                      upToDateUser,
                                      _firstNameController.text.trim(),
                                      _lastNameController.text.trim(),
                                      _phoneController.text.trim(),
                                      _addressController.text.trim(),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully.')));
                                  }
                                },
                                child: const Text('SAVE CHANGES'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Active Rentals List
                Text('RECENT ACTIVITY', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (userRequests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history_toggle_off, size: 64, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'No recent rentals',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Browse the catalog to make your first reservation.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userRequests.length,
                    itemBuilder: (context, index) {
                      final req = userRequests[index];
                      final item = dataService.items.firstWhere((i) => i.id == req.itemId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${DateFormat('MMM d, yyyy').format(req.startDate)} - ${DateFormat('MMM d, yyyy').format(req.returnDate)}'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
