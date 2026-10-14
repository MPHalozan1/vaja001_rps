import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/bill.dart';
import '../services/data_service.dart';

class BillingDashboardScreen extends StatefulWidget {
  final User currentUser;
  const BillingDashboardScreen({super.key, required this.currentUser});

  @override
  State<BillingDashboardScreen> createState() => _BillingDashboardScreenState();
}

class _BillingDashboardScreenState extends State<BillingDashboardScreen> {
  BillStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final bills = dataService.bills
        .where((b) => _filterStatus == null || b.status == _filterStatus)
        .toList();

    double totalRevenue = dataService.bills
        .where((b) => b.status == BillStatus.paid)
        .fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Billing & Invoicing')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Total Revenue (Paid)'),
                              Text(
                                '\$${totalRevenue.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    DropdownButton<BillStatus?>(
                      value: _filterStatus,
                      hint: const Text('Filter by Status'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Bills'),
                        ),
                        ...BillStatus.values.map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text(s.name)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => _filterStatus = val);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    String customerName = 'Unknown';
                    try {
                      customerName = dataService.users
                          .firstWhere((u) => u.id == bill.customerId)
                          .name;
                    } catch (_) {}
                    String itemName = 'Unknown';
                    String dates = '';
                    if (bill.borrowRequestId != null) {
                      try {
                        final req = dataService.borrowRequests.firstWhere(
                          (r) => r.id == bill.borrowRequestId,
                        );
                        final item = dataService.items.firstWhere(
                          (i) => i.id == req.itemId,
                        );
                        itemName = item.name;
                        dates =
                            '${req.startDate.toString().split(' ')[0]} to ${req.returnDate.toString().split(' ')[0]}';
                      } catch (_) {}
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bill ID: ${bill.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${bill.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Customer: $customerName'),
                            if (bill.borrowRequestId != null) ...[
                              Text('Item: $itemName'),
                              Text('Dates: $dates'),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(bill.status.name),
                                  backgroundColor:
                                      bill.status == BillStatus.unpaid
                                      ? Colors.red.withValues(alpha: 0.2)
                                      : null,
                                ),
                                Row(
                                  children: [
                                    if (bill.status ==
                                        BillStatus.pendingAdminApproval)
                                      FilledButton.tonal(
                                        onPressed: () {
                                          try {
                                            final msg = dataService
                                                .approveEmployeeBill(
                                                  widget.currentUser,
                                                  bill.id,
                                                );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(content: Text(msg)),
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
                                        child: const Text('Approve'),
                                      )
                                    else if (bill.status ==
                                            BillStatus.approved ||
                                        bill.status == BillStatus.unpaid)
                                      FilledButton.tonal(
                                        onPressed: () {
                                          setState(() {
                                            bill.status = BillStatus.paid;
                                          });
                                        },
                                        child: const Text('Mark Paid'),
                                      ),
                                  ],
                                ),
                              ],
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
      ),
    );
  }
}
