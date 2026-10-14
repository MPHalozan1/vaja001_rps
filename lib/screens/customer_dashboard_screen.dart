import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../services/data_service.dart';

/// Uporabniška nadzorna plošča za spremljanje statusov svojih Ticketov,
/// preklic čakajočih rezervacij in podaljšanje aktivnih najemov (+2 dni).
class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final user = data.currentUser;
        if (user == null) return const SizedBox.shrink();

        final myRequests = data.getRequestsForUser(user.id);
        final pendingCount =
            myRequests.where((r) => r.status == BorrowStatus.pending).length;
        final activeCount =
            myRequests.where((r) => r.status == BorrowStatus.approved).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _MetricSummaryCard(
                    title: 'Pending Tickets',
                    value: '$pendingCount',
                    subtitle: 'Waiting for Employee approval',
                    color: const Color(0xFFF59E0B),
                    icon: Icons.hourglass_top_rounded,
                  ),
                  _MetricSummaryCard(
                    title: 'Active Rentals',
                    value: '$activeCount',
                    subtitle: 'Currently approved & in use',
                    color: cs.primary,
                    icon: Icons.inventory_2_rounded,
                  ),
                  _MetricSummaryCard(
                    title: 'Total Tickets History',
                    value: '${myRequests.length}',
                    subtitle: 'All submitted requests',
                    color: const Color(0xFF10B981),
                    icon: Icons.history_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'My Reservation Tickets',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              if (myRequests.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Center(
                    child: Text(
                      'You have not submitted any reservation tickets yet. Visit the Store Catalog to reserve gear.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myRequests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = myRequests[index];
                    return _CustomerTicketTile(
                      request: req,
                      onCancel: req.status == BorrowStatus.pending
                          ? () => data.cancelBorrowRequest(req.id)
                          : null,
                      onExtend: req.status == BorrowStatus.approved
                          ? () {
                              data.extendActiveRental(req.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Extended #${req.id} by +2 days! Invoice updated.',
                                  ),
                                ),
                              );
                            }
                          : null,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _MetricSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 270,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTicketTile extends StatelessWidget {
  final BorrowRequest request;
  final VoidCallback? onCancel;
  final VoidCallback? onExtend;

  const _CustomerTicketTile({
    required this.request,
    this.onCancel,
    this.onExtend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = switch (request.status) {
      BorrowStatus.pending => const Color(0xFFF59E0B),
      BorrowStatus.approved => cs.primary,
      BorrowStatus.returned => const Color(0xFF10B981),
      BorrowStatus.rejected => const Color(0xFFEF4444),
      BorrowStatus.cancelled => const Color(0xFF64748B),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${request.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${request.quantity}x ${request.itemName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Duration: ${request.durationDays} days • Total: €${request.totalCost.toStringAsFixed(2)}${request.discountPercent > 0 ? " (-${request.discountPercent.toInt()}% promo)" : ""}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              if (request.handledByStaffName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Processed by: ${request.handledByStaffName}${request.staffNote != null && request.staffNote!.isNotEmpty ? " — Note: ${request.staffNote}" : ""}',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              if (onExtend != null) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onExtend,
                  icon: const Icon(Icons.more_time_rounded, size: 16),
                  label: const Text('+2 Days'),
                ),
              ],
              if (onCancel != null) ...[
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel Ticket'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}