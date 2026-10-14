import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import '../models/bill.dart';

class NotificationBell extends StatelessWidget {
  final User currentUser;
  const NotificationBell({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    List<String> notifications = [];

    if (currentUser.role == UserRole.admin) {
      final pendingBills = dataService.bills
          .where((b) => b.status == BillStatus.pendingAdminApproval)
          .length;
      if (pendingBills > 0)
        notifications.add('$pendingBills bills pending your approval.');
      final pendingCats = dataService.pendingCategories.length;
      if (pendingCats > 0)
        notifications.add('$pendingCats new categories requested.');
    } else if (currentUser.role == UserRole.employee) {
      final damagedItems = dataService.items.where((i) => i.isDamaged).length;
      if (damagedItems > 0)
        notifications.add('$damagedItems items waiting in maintenance queue.');
    } else if (currentUser.role == UserRole.customer) {
      final unreadBills = dataService.bills
          .where(
            (b) =>
                b.customerId == currentUser.id && b.status == BillStatus.unpaid,
          )
          .length;
      if (unreadBills > 0)
        notifications.add('You have $unreadBills unpaid bills.');
      if (currentUser.strikes > 0)
        notifications.add(
          'Warning: You have ${currentUser.strikes} strikes on your account.',
        );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NOTIFICATIONS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No new notifications.'),
                        )
                      else
                        ...notifications.map(
                          (n) => ListTile(
                            leading: Icon(
                              Icons.info,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(n),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        if (notifications.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${notifications.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
