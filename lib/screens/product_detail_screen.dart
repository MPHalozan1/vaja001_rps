import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// Zaslon s podrobnostmi o opremi, Hero animacijo in konfiguratorjem za rezervacijo.
class ProductDetailScreen extends StatefulWidget {
  final String itemId;

  const ProductDetailScreen({super.key, required this.itemId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _dataService = DataService.instance;
  int _quantity = 1;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 3)),
  );
  final _noteController = TextEditingController();
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final item = _dataService.getItemById(widget.itemId);
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item Not Found')),
            body: const Center(child: Text('This item was removed.')),
          );
        }

        final durationDays = _dateRange.duration.inDays <= 0
            ? 1
            : _dateRange.duration.inDays;
        final discount =
            _dataService.evaluatePromoCode(_promoController.text);
        final gross = item.dailyRate * durationDays * _quantity;
        final totalCost = gross * ((100 - discount) / 100);

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Kartica z informacijami in specifikacijami
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Hero(
                                tag: 'item_icon_${item.id}',
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 40,
                                    color: cs.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category.toUpperCase(),
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '€${item.dailyRate.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                    ),
                                  ),
                                  Text(
                                    'per day',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: cs.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'TECHNICAL SPECIFICATIONS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: item.specs.entries.map((e) {
                              return Container(
                                width: 200,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest
                                      .withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.outlineVariant),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.key,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      e.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Konfigurator za oddajo novega Ticketa
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Reservation Ticket',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select your dates and quantity. Once submitted, an Employee or Admin will review and approve your ticket.',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickDateRange,
                                icon: const Icon(Icons.date_range_rounded),
                                label: Text(
                                  '${_formatDate(_dateRange.start)} → ${_formatDate(_dateRange.end)} ($durationDays days)',
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Units: '),
                                  IconButton(
                                    onPressed: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                    icon: const Icon(
                                        Icons.remove_circle_outline_rounded),
                                  ),
                                  Text(
                                    '$_quantity / ${item.availableStock}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _quantity < item.availableStock
                                        ? () => setState(() => _quantity++)
                                        : null,
                                    icon: const Icon(
                                        Icons.add_circle_outline_rounded),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText:
                                        'Promo Code (RPS10 / STUDENT20)',
                                    prefixIcon:
                                        const Icon(Icons.local_offer_outlined),
                                    suffixText: discount > 0
                                        ? '-${discount.toInt()}%'
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _noteController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Notes for Employee Approval (Optional)',
                                    prefixIcon: Icon(Icons.notes_rounded),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    discount > 0
                                        ? 'Total Rental Fee (${discount.toInt()}% Discount Applied)'
                                        : 'Total Estimated Rental Fee',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '€${totalCost.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                    ),
                                  ),
                                ],
                              ),
                              FilledButton.icon(
                                onPressed: item.isAvailable
                                    ? () {
                                        final ticket =
                                            _dataService.createBorrowRequest(
                                          itemId: item.id,
                                          quantity: _quantity,
                                          startDate: _dateRange.start,
                                          endDate: _dateRange.end,
                                          customNote: _noteController.text,
                                          promoCode: _promoController.text,
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                              'Ticket #${ticket.id} submitted for Employee approval!',
                                            ),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    : null,
                                icon: const Icon(
                                    Icons.confirmation_number_rounded),
                                label: const Text('Submit Reservation Ticket'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}