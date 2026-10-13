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
  String _selectedCategory = 'All';

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'IT':
        return Icons.computer;
      case 'Household':
        return Icons.home;
      case 'Audio/Video':
        return Icons.videocam;
      default:
        return Icons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final allItems = dataService.items;

    // Get unique categories for the tabs
    final categories = ['All', ...allItems.map((e) => e.category).toSet()];

    final filteredItems = allItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
                            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            item.subcategory.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Search items by name...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    avatar: category != 'All' ? Icon(_getIconForCategory(category), size: 18) : null,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No items found.',
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
                      final isAvailable = dataService.checkItemAvailability(item.id, DateTime.now(), DateTime.now()); // Quick check, simplified

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 160,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  _getIconForCategory(item.category),
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          '\$${item.pricePerDay}/day',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.category} > ${item.subcategory}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Availability status
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: isAvailable ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isAvailable ? 'Available' : 'Reserved',
                                          style: TextStyle(
                                            color: isAvailable ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (reservations.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Unavailable dates:',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      ...reservations.map((r) => Text(
                                            '- ${DateFormat('MMM d').format(r.startDate)} to ${DateFormat('MMM d').format(r.returnDate)}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
                                          )),
                                    ],

                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton.tonal(
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
                            ),
                          ],
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
