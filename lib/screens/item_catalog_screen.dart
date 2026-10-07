import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import 'borrow_form_screen.dart';
import 'package:intl/intl.dart';

class ItemCatalogScreen extends StatelessWidget {
  final User currentUser;

  const ItemCatalogScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final items = dataService.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Item Catalog')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final reservations = dataService.getReservationsForItem(item.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.name, style: Theme.of(context).textTheme.titleLarge),
                      Text('\$${item.pricePerDay}/day', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${item.category} > ${item.subcategory}'),
                  const SizedBox(height: 8),
                  if (reservations.isNotEmpty) ...[
                    const Text('Currently Reserved Dates:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...reservations.map((r) => Text('- ${DateFormat('MMM d, y').format(r.startDate)} to ${DateFormat('MMM d, y').format(r.returnDate)}')),
                    const SizedBox(height: 8),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BorrowFormScreen(currentUser: currentUser, item: item),
                          ),
                        );
                      },
                      child: const Text('Reserve'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
