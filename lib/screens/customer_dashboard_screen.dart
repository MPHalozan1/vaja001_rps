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
  late TextEditingController _nameController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _contactController = TextEditingController(text: widget.currentUser.contactInfo);
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
      body: SingleChildScrollView(
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
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(Icons.person)),
                        validator: (v) => v!.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Contact Info', prefixIcon: Icon(Icons.contact_mail)),
                        validator: (v) => v!.isEmpty ? 'Contact required' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              dataService.updateUserProfile(upToDateUser, _nameController.text, _contactController.text);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
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
            const SizedBox(height: 32),

            // Active Rentals List
            Text('RECENT ACTIVITY', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (userRequests.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No recent rentals.', style: TextStyle(color: Colors.grey))),
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
