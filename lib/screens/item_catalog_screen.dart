import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/data_service.dart';
import '../widgets/hover_scale_wrapper.dart';
import 'product_detail_screen.dart';

/// Katalog opreme (Store Page) s čistim dizajnom, filtri, priljubljenimi izdelki (Favorites)
/// in hitro oddajo Ticketa s podporo za promo kode (npr. RPS10).
class ItemCatalogScreen extends StatefulWidget {
  const ItemCatalogScreen({super.key});

  @override
  State<ItemCatalogScreen> createState() => _ItemCatalogScreenState();
}

class _ItemCatalogScreenState extends State<ItemCatalogScreen> {
  final _dataService = DataService.instance;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _onlyAvailable = false;
  bool _onlyFavorites = false;
  String _sortBy = 'popular';

  List<Item> _getFilteredItems() {
    var list = _dataService.items.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesAvailability = !_onlyAvailable || item.isAvailable;
      final matchesFavorites =
          !_onlyFavorites || _dataService.isFavorite(item.id);
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      return matchesCategory &&
          matchesAvailability &&
          matchesFavorites &&
          matchesSearch;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.dailyRate.compareTo(b.dailyRate));
        break;
      case 'price_desc':
        list.sort((a, b) => b.dailyRate.compareTo(a.dailyRate));
        break;
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'popular':
      default:
        list.sort(
            (a, b) => b.totalRentalsCount.compareTo(a.totalRentalsCount));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final filteredItems = _getFilteredItems();
        final categories = _dataService.categories;

        return CustomScrollView(
          slivers: [
            // 1. Zgornja nadzorna plošča trgovine (Search, Filters, Sort)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 260,
                            maxWidth: 420,
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText:
                                  'Search cameras, drones, lighting, specs...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      onPressed: () =>
                                          setState(() => _searchQuery = ''),
                                      icon: const Icon(Icons.clear_rounded),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        FilterChip(
                          label: const Text('In Stock Only'),
                          selected: _onlyAvailable,
                          onSelected: (v) =>
                              setState(() => _onlyAvailable = v),
                        ),
                        FilterChip(
                          avatar: Icon(
                            _onlyFavorites
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: _onlyFavorites
                                ? const Color(0xFFE11D48)
                                : cs.onSurfaceVariant,
                          ),
                          label: const Text('Saved'),
                          selected: _onlyFavorites,
                          onSelected: (v) =>
                              setState(() => _onlyFavorites = v),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'popular',
                                  child: Text('Sort: Most Popular'),
                                ),
                                DropdownMenuItem(
                                  value: 'price_asc',
                                  child: Text('Sort: Daily Rate (Low → High)'),
                                ),
                                DropdownMenuItem(
                                  value: 'price_desc',
                                  child: Text('Sort: Daily Rate (High → Low)'),
                                ),
                                DropdownMenuItem(
                                  value: 'name',
                                  child: Text('Sort: Alphabetical'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _sortBy = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Kategorije
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = category),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Odzivna mreža kartic opreme
            if (filteredItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No equipment matches your current filter criteria.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 390,
                    mainAxisExtent: 345,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return _StoreItemCard(
                        item: item,
                        isFavorite: _dataService.isFavorite(item.id),
                        onToggleFavorite: () =>
                            _dataService.toggleFavorite(item.id),
                        onOpenDetails: () {
                          // Gladka animirana navigacija s Hero prehodom
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 320),
                              pageBuilder: (_, animation, _) => FadeTransition(
                                opacity: animation,
                                child: ProductDetailScreen(itemId: item.id),
                              ),
                            ),
                          );
                        },
                        onQuickReserve: () =>
                            _showQuickReservationDialog(context, item),
                      );
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Modalno okno za hitro oddajo Ticketa s podporo za promo kodo
  void _showQuickReservationDialog(BuildContext context, Item item) {
    int quantity = 1;
    int days = 3;
    final noteController = TextEditingController();
    final promoController = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final discount =
                _dataService.evaluatePromoCode(promoController.text);
            final gross = item.dailyRate * days * quantity;
            final total = gross * ((100 - discount) / 100);

            return AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cs.outlineVariant),
              ),
              title: Text(
                'Reserve ${item.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submits a reservation ticket to the Employee / Admin queue.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quantity:'),
                          Row(
                            children: [
                              IconButton(
                                onPressed: quantity > 1
                                    ? () => setDialogState(() => quantity--)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '$quantity / ${item.availableStock}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: quantity < item.availableStock
                                    ? () => setDialogState(() => quantity++)
                                    : null,
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Rental Duration (Days):'),
                          DropdownButton<int>(
                            value: days,
                            items: [1, 2, 3, 5, 7, 10, 14]
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text('$d days'),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setDialogState(() => days = v);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: promoController,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Promo Code (Try: RPS10 or STUDENT20)',
                          prefixIcon: const Icon(Icons.local_offer_outlined),
                          suffixText:
                              discount > 0 ? '-${discount.toInt()}%' : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Project / Notes for Staff (Optional)',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              discount > 0
                                  ? 'Total (${discount.toInt()}% off):'
                                  : 'Estimated Total:',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                            Text(
                              '€${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    try {
                      final now = DateTime.now();
                      final ticket = _dataService.createBorrowRequest(
                        itemId: item.id,
                        quantity: quantity,
                        startDate: now,
                        endDate: now.add(Duration(days: days)),
                        customNote: noteController.text,
                        promoCode: promoController.text,
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Ticket #${ticket.id} created! An Employee can now approve it.',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                  label: const Text('Submit Ticket'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final Item item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenDetails;
  final VoidCallback onQuickReserve;

  const _StoreItemCard({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenDetails,
    required this.onQuickReserve,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stockColor = item.underMaintenance
        ? const Color(0xFFF59E0B)
        : item.isAvailable
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);

    return HoverScaleWrapper(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zgornja vrstica: Hero ikona + Kategorija + Priljubljeno
            Row(
              children: [
                Hero(
                  tag: 'item_icon_${item.id}',
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      color: cs.primary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Save to Favorites',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? const Color(0xFFE11D48)
                        : cs.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Hitre tehnične specifikacije
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.specs.entries.take(2).map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Divider(color: cs.outlineVariant, height: 22),
            // Cena in status zaloge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '€${item.dailyRate.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ' / day',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.underMaintenance
                        ? 'In Service'
                        : item.isAvailable
                            ? '${item.availableStock}/${item.totalStock} Available'
                            : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: stockColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Akcijska gumba
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpenDetails,
                    child: const Text('Specs & Info'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: item.isAvailable ? onQuickReserve : null,
                    icon: const Icon(Icons.add_task_rounded, size: 17),
                    label: const Text('Reserve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}