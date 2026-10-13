import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import '../models/item.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final User currentUser;
  final Item item;

  const ProductDetailScreen({
    super.key,
    required this.currentUser,
    required this.item,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  DateTimeRange? _selectedDateRange;

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'IT':
        return Icons.computer;
      case 'Household':
        return Icons.home;
      case 'Audio/Video':
        return Icons.videocam;
      default:
        return Icons.inventory_2;
    }
  }

  void _reserveItem(DataService dataService) {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range.')),
      );
      return;
    }

    try {
      dataService.processItemReservation(
        widget.currentUser,
        widget.item.id,
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation successful!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final reservations = dataService.getReservationsForItem(widget.item.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image Area
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'item-${widget.item.id}',
                  child: Icon(
                    _getIconForCategory(widget.item.category),
                    size: 150,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item.category.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                        ),
                        child: Text(
                          '\$${widget.item.pricePerDay.toStringAsFixed(2)} / DAY',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subcategory: ${widget.item.subcategory}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Technical Specifications DataTable
                  if (widget.item.specs.isNotEmpty) ...[
                    Text(
                      'Technical Specifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: DataTable(
                          headingRowHeight: 0, // Hide header
                          columns: const [
                            DataColumn(label: Text('Spec')),
                            DataColumn(label: Text('Value')),
                          ],
                          rows: widget.item.specs.entries.map((e) {
                            return DataRow(
                              cells: [
                                DataCell(Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(e.value)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Check Availability & Reserve',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  if (reservations.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event_busy, color: Theme.of(context).colorScheme.onErrorContainer),
                              const SizedBox(width: 8),
                              Text(
                                'Currently Reserved Dates',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...reservations.map((r) => Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '• ${DateFormat('MMM d, yyyy').format(r.startDate)} - ${DateFormat('MMM d, yyyy').format(r.returnDate)}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary),
                      title: Text(
                        _selectedDateRange == null
                            ? 'Select Reservation Dates'
                            : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final now = DateTime.now();
                        // Cache context-dependent objects before async gap
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365)),
                          initialDateRange: _selectedDateRange,
                        );

                        if (picked != null) {
                          // Validate availability specifically for the chosen dates
                          bool available = dataService.checkItemAvailability(widget.item.id, picked.start, picked.end);
                          if (!available) {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Item is not available for the selected dates. Please check the reserved dates above.'), backgroundColor: Colors.red),
                            );
                            setState(() => _selectedDateRange = null);
                          } else {
                            setState(() => _selectedDateRange = picked);
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _reserveItem(dataService),
                      child: Text(
                        'CONFIRM RESERVATION',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
