import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import 'product_detail_screen.dart';

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
      case 'IT': return Icons.computer;
      case 'Household': return Icons.home;
      case 'Audio/Video': return Icons.videocam;
      default: return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final allItems = dataService.items;
    final categories = ['All', ...allItems.map((e) => e.category).toSet()];
    final bool isWide = MediaQuery.of(context).size.width >= 800;

    final filteredItems = allItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
                            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            item.subcategory.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    Widget buildMainContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search Bar Constrained
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SearchBar(
                hintText: 'Search items...',
                leading: const Icon(Icons.search),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          // Categories chips for mobile
          if (!isWide)
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
                      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
                      ),
                      onSelected: (selected) => setState(() => _selectedCategory = category),
                    ),
                  );
                }).toList(),
              ),
            ),

          if (!isWide) const SizedBox(height: 16),

          // Product Grid
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 64, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(height: 16),
                        const Text('NO ITEMS FOUND', style: TextStyle(letterSpacing: 2)),
                      ],
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isAvailable = dataService.checkItemAvailability(item.id, DateTime.now(), DateTime.now());

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                if (widget.currentUser.role == UserRole.customer) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        currentUser: widget.currentUser,
                                        item: item,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Only customers can reserve items from Catalog.')),
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Hero(
                                              tag: 'item-${item.id}',
                                              child: Icon(
                                                _getIconForCategory(item.category),
                                                size: 64,
                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.7),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '\$${item.pricePerDay}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 10,
                                                color: isAvailable ? Colors.green : Colors.red,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isAvailable ? 'AVAILABLE' : 'RESERVED',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  letterSpacing: 1,
                                                  color: isAvailable ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sticky Sidebar for Wide Screens
                SizedBox(
                  width: 250,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Text('Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return ListTile(
                          title: Text(category),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onTap: () => setState(() => _selectedCategory = category),
                        );
                      }),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: buildMainContent()),
              ],
            )
          : buildMainContent(),
    );
  }
}
