import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import '../models/item.dart';

class BorrowFormScreen extends StatefulWidget {
  final User currentUser;
  final Item item;

  const BorrowFormScreen({super.key, required this.currentUser, required this.item});

  @override
  State<BorrowFormScreen> createState() => _BorrowFormScreenState();
}

class _BorrowFormScreenState extends State<BorrowFormScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);

    int days = 0;
    if (_startDate != null && _endDate != null) {
      days = _endDate!.difference(_startDate!).inDays + 1;
    }
    final double totalPrice = days * widget.item.pricePerDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Reserve Item')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Item: ${widget.item.name}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Price: \$${widget.item.pricePerDay}/day'),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate == null ? 'Start Date' : DateFormat('MMM d, y').format(_startDate!)),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                            _endDate = null;
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate == null ? 'End Date' : DateFormat('MMM d, y').format(_endDate!)),
                    onPressed: _startDate == null ? null : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate!,
                        firstDate: _startDate!,
                        lastDate: _startDate!.add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_startDate != null && _endDate != null) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Duration: $days days', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Estimated Total: \$${totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  try {
                    dataService.addBorrowRequest(widget.currentUser, widget.item.id, _startDate!, _endDate!);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item successfully reserved')));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                  }
                },
                child: const Text('Confirm Reservation'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
