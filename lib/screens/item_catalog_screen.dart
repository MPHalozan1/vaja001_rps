import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import 'borrow_form_screen.dart';
import 'package:intl/intl.dart';

class ItemCatalogScreen extends StatefulWidget {
  final User currentUser;

  const ItemCatalogScreen({super.key, required this.currentUser});

  @override
  State<ItemCatalogScreen> createState() => _ItemCatalogScreenState();
}

class _ItemCatalogScreenState extends State<ItemCatalogScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final allItems = dataService.items;

    final filteredItems = allItems.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(query) ||
             item.category.toLowerCase().contains(query) ||
             item.subcategory.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Item Catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Search by name, category, or subcategory',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No items found matching "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
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
                                  Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleLarge)),
                                  Text('\$${item.pricePerDay}/day', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${item.category} > ${item.subcategory}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                                        builder: (context) => BorrowFormScreen(currentUser: widget.currentUser, item: item),
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
          ),
        ],
      ),
    );
  }
}
