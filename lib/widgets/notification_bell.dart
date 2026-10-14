import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// Zvonček za obvestila, ki se prilagaja Light in Dark temi ter prikazuje število neprebranih obvestil.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final unreadCount = data.unreadNotificationCount;

        return IconButton(
          tooltip: 'Notifications',
          onPressed: () => _showNotificationsSheet(context, data),
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            backgroundColor: cs.primary,
            textColor: cs.onPrimary,
            label: Text(
              unreadCount > 9 ? '9+' : '$unreadCount',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context, DataService data) {
    final notifications = data.notificationsForCurrentUser;
    data.markAllNotificationsRead();
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activity & Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      '${notifications.length} events',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: cs.outlineVariant),
                if (notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No notifications yet.',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) =>
                          Divider(color: cs.outlineVariant, height: 16),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: cs.primary.withValues(alpha: 0.14),
                            child: Icon(
                              Icons.bolt_rounded,
                              color: cs.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.message,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}