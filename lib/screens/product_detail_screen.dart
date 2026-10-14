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
  final TextEditingController _locationController = TextEditingController();
  bool _liabilityAccepted = false;

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
      if (!_liabilityAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You must accept the liability disclaimer to proceed.',
            ),
          ),
        );
        return;
      }
      if (_locationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter intended location of use.'),
          ),
        );
        return;
      }
      dataService.processItemReservation(
        widget.currentUser,
        widget.item.id,
        _selectedDateRange!.start,
        _selectedDateRange!.end,
        location: _locationController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reservation successful!')));
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: SingleChildScrollView(
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
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
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

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                              ),
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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subcategory: ${widget.item.subcategory}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Specs Table
                      if (widget.item.specs.isNotEmpty) ...[
                        Text(
                          'TECHNICAL SPECIFICATIONS',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: widget.item.specs.entries.map((e) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 3, child: Text(e.value)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Base Specs Grid
                      Row(
                        children: [
                          _buildSpecCard(
                            context,
                            'Total Qty',
                            widget.item.totalQuantity.toString(),
                            Icons.layers,
                          ),
                          const SizedBox(width: 16),
                          _buildSpecCard(
                            context,
                            'Condition',
                            'Excellent',
                            Icons.check_circle_outline,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'AVAILABILITY CALENDAR',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Availability Timeline List
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 30, // Show next 30 days
                          itemBuilder: (context, index) {
                            final date = DateTime.now().add(
                              Duration(days: index),
                            );
                            final normalizedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                            final isAvailable = dataService
                                .checkItemAvailability(
                                  widget.item.id,
                                  normalizedDate,
                                  normalizedDate,
                                );

                            return Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest
                                    : Theme.of(context)
                                          .colorScheme
                                          .errorContainer
                                          .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isAvailable
                                      ? Theme.of(context).colorScheme.outline
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('MMM').format(date),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    date.day.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    isAvailable
                                        ? Icons.check_circle
                                        : Icons.block,
                                    size: 16,
                                    color: isAvailable
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      Card(
                        elevation: 0,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.date_range,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            _selectedDateRange == null
                                ? 'Select Reservation Dates'
                                : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 365)),
                              initialDateRange: _selectedDateRange,
                            );

                            if (picked != null) {
                              // Verify the entire range is available
                              if (dataService.checkItemAvailability(
                                widget.item.id,
                                picked.start,
                                picked.end,
                              )) {
                                setState(() {
                                  _selectedDateRange = picked;
                                });
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'One or more dates in the selected range are unavailable.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Intended Location of Use *',
                          helperText: 'E.g., Conference Room A, Building 4',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('I accept the liability controls and conditions *'),
                        subtitle: const Text('By checking this, you agree to be responsible for any damages or loss.'),
                        value: _liabilityAccepted,
                        onChanged: (bool? value) {
                          setState(() {
                            _liabilityAccepted = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _reserveItem(dataService),
                              child: Text(
                                'CONFIRM RESERVATION',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
