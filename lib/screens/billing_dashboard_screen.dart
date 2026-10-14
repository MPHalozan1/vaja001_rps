import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/data_service.dart';

/// Zaslon za račune in plačila.
/// Stranke tukaj plačajo račune, Employee potrjuje prejeta plačila, Admin pa ima dodatne pravice za popuste in odpis.
class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final user = data.currentUser;
        if (user == null) return const SizedBox.shrink();

        final displayedBills =
            user.isStaff ? data.bills : data.getBillsForUser(user.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.isStaff
                    ? 'All Customer Invoices & Payment Approvals'
                    : 'My Invoices & Payments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user.isAdmin
                    ? 'Admin Mode: Verify payments to update ROI graphs, or apply executive discounts/waivers.'
                    : user.isEmployee
                        ? 'Employee Mode: Verify customer invoice payments.'
                        : 'Pay your approved rental invoices below.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 20),
              if (displayedBills.isEmpty)
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
                      'No invoices generated yet. Invoices are automatically created when an Employee approves a ticket.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedBills.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bill = displayedBills[index];
                    final statusColor = switch (bill.status) {
                      BillStatus.paid => const Color(0xFF10B981),
                      BillStatus.pendingApproval => const Color(0xFFF59E0B),
                      BillStatus.unpaid => cs.primary,
                      BillStatus.overdue => const Color(0xFFEF4444),
                      BillStatus.waived => const Color(0xFF64748B),
                    };

                    final canModify = bill.status != BillStatus.paid &&
                        bill.status != BillStatus.waived;

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
                                    '${bill.id} (Ticket #${bill.borrowRequestId})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          statusColor.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      bill.statusLabel,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${bill.itemName} • Customer: ${bill.userName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: cs.onSurface,
                                ),
                              ),
                              if (bill.penaltyFee > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Includes €${bill.penaltyFee.toStringAsFixed(2)} late/damage inspection fee',
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '€${bill.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Gumb za stranko
                              if (!user.isStaff &&
                                  (bill.status == BillStatus.unpaid ||
                                      bill.status == BillStatus.overdue))
                                FilledButton.icon(
                                  onPressed: () => data
                                      .requestBillPaymentApproval(bill.id),
                                  icon: const Icon(Icons.payment_rounded,
                                      size: 18),
                                  label: const Text('Pay Invoice'),
                                ),
                              // Ekskluzivne akcije samo za Admina (-20% ali Waive)
                              if (user.isAdmin && canModify) ...[
                                OutlinedButton(
                                  onPressed: () =>
                                      data.applyAdminDiscountOrWaive(
                                    bill.id,
                                    waiveCompletely: false,
                                  ),
                                  child: const Text('Admin -20%'),
                                ),
                                const SizedBox(width: 8),
                              ],
                              // Akcija za Employee in Admin (potrditev plačila)
                              if (user.isStaff && canModify)
                                FilledButton.icon(
                                  onPressed: () =>
                                      data.approveBillPayment(bill.id),
                                  icon: const Icon(Icons.check_circle_rounded,
                                      size: 18),
                                  label: const Text('Verify Paid'),
                                ),
                            ],
                          ),
                        ],
                      ),
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