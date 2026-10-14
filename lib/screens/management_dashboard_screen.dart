import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/data_service.dart';

/// Nadzorna plošča za osebje z jasno ločenimi pravicami:
/// - Employee: 2 operativna zavihka (Tickets & Approvals + Inventory Stock/Service)
/// - Admin: 5 zavihkov (Tickets, Animated ROI Graph, Full Inventory CRUD, User Roles, System Audit Log)
class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() =>
      _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  final _data = DataService.instance;
  String _selectedRoiCategory = 'All';
  bool _showBreakEvenMode = false; // Preklop pogleda grafa

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _data,
      builder: (context, _) {
        final user = _data.currentUser;
        if (user == null || !user.isStaff) {
          return const Center(child: Text('Access Restricted to Staff.'));
        }

        final isAdmin = user.isAdmin;
        final pendingTicketsCount = _data.pendingTickets.length;

        // Dinamični zavihki glede na to, ali je prijavljen Employee ali Admin
        final tabs = <Tab>[
          Tab(
            icon: const Icon(Icons.confirmation_number_outlined),
            text: 'Tickets & Approvals ($pendingTicketsCount)',
          ),
          const Tab(
            icon: Icon(Icons.inventory_2_outlined),
            text: 'Inventory Control',
          ),
          if (isAdmin) ...[
            const Tab(
              icon: Icon(Icons.bar_chart_rounded),
              text: 'ROI Financial Graph (Admin)',
            ),
            const Tab(
              icon: Icon(Icons.manage_accounts_outlined),
              text: 'Users & Roles (Admin)',
            ),
            const Tab(
              icon: Icon(Icons.fact_check_outlined),
              text: 'Audit Log (Admin)',
            ),
          ],
        ];

        final views = <Widget>[
          _buildTicketsApprovalTab(cs),
          _buildInventoryTab(cs, isAdmin: isAdmin),
          if (isAdmin) ...[
            _buildRoiGraphTab(cs),
            _buildUsersTab(cs),
            _buildAuditLogTab(cs),
          ],
        ];

        return DefaultTabController(
          key: ValueKey('staff_tabs_${isAdmin ? 5 : 2}'),
          length: tabs.length,
          child: Column(
            children: [
              Container(
                color: cs.surface,
                width: double.infinity,
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: cs.primary,
                  labelColor: cs.primary,
                  unselectedLabelColor: cs.onSurfaceVariant,
                  tabs: tabs,
                ),
              ),
              Divider(color: cs.outlineVariant, height: 1),
              Expanded(
                child: TabBarView(
                  children: views,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TAB 1: POTRJEVANJE TICKETOV IN PREGLED OB VRAČILU (EMPLOYEE & ADMIN)
  // ===========================================================================
  Widget _buildTicketsApprovalTab(ColorScheme cs) {
    final requests = _data.borrowRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reservation Ticket Queue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Approve new customer reservation tickets to allocate stock and issue an invoice, or inspect returned gear.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (requests.isEmpty)
            const Center(child: Text('No tickets in system.'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final req = requests[index];
                final isPending = req.status == BorrowStatus.pending;
                final isApproved = req.status == BorrowStatus.approved;

                final badgeColor = switch (req.status) {
                  BorrowStatus.pending => const Color(0xFFF59E0B),
                  BorrowStatus.approved => cs.primary,
                  BorrowStatus.returned => const Color(0xFF10B981),
                  BorrowStatus.rejected => const Color(0xFFEF4444),
                  BorrowStatus.cancelled => const Color(0xFF64748B),
                };

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPending
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 14,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${req.id} • ${req.statusLabel}',
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${req.quantity}x ${req.itemName}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Customer: ${req.userName} (${req.userEmail}) • Duration: ${req.durationDays} days • Total: €${req.totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          if (req.staffNote != null &&
                              req.staffNote!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Note: "${req.staffNote}"',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (req.returnConditionNote != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Return Inspection: ${req.returnConditionNote}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPending) ...[
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _data.rejectBorrowRequest(req.id),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                              ),
                              label: const Text('Reject'),
                            ),
                            const SizedBox(width: 10),
                            FilledButton.icon(
                              onPressed: () {
                                try {
                                  _data.approveBorrowRequest(req.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        'Ticket #${req.id} approved and invoice issued!',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Approve Ticket'),
                            ),
                          ] else if (isApproved)
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  _showReturnInspectionDialog(context, req),
                              icon: const Icon(
                                  Icons.assignment_returned_rounded,
                                  size: 18),
                              label: const Text('Inspect & Return'),
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
  }

  /// Modalno okno ob vračilu opreme: Employee preveri stanje opreme (Brezhibno vs. Poškodba/Zamuda)
  void _showReturnInspectionDialog(BuildContext context, BorrowRequest req) {
    bool hasIssue = false;
    final feeCtrl = TextEditingController(text: '45');
    final noteCtrl =
        TextEditingController(text: 'Returned clean and tested OK.');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Return Inspection (#${req.id})'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item: ${req.quantity}x ${req.itemName}'),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Damage or Late Return Penalty?'),
                    subtitle: const Text(
                        'Adds inspection surcharge to customer invoice'),
                    value: hasIssue,
                    onChanged: (val) {
                      setDialogState(() {
                        hasIssue = val;
                        noteCtrl.text = val
                            ? 'Minor scratch / late return surcharge applied.'
                            : 'Returned clean and tested OK.';
                      });
                    },
                  ),
                  if (hasIssue) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: feeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Penalty / Repair Fee (€)',
                        prefixIcon: Icon(Icons.euro_rounded),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Inspection Note',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final fee = hasIssue
                        ? (double.tryParse(feeCtrl.text) ?? 0.0)
                        : 0.0;
                    _data.markItemReturned(
                      req.id,
                      damageOrLateFee: fee,
                      conditionNote: noteCtrl.text,
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Confirm Return'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // TAB 2: INVENTAR (EMPLOYEE IMA OPERATIVNI DOSTOP, ADMIN POLNI CRUD)
  // ===========================================================================
  Widget _buildInventoryTab(ColorScheme cs, {required bool isAdmin}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment Inventory Control',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAdmin
                        ? 'Admin Privileges: Add new equipment, adjust pricing/costs, toggle maintenance, or delete items.'
                        : 'Employee Privileges: Toggle service maintenance mode. Adding/deleting catalog items requires Admin role.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
              if (isAdmin)
                FilledButton.icon(
                  onPressed: () => _showAddItemDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add New Equipment'),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Catalog Creation Locked (Admin Only)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _data.items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, color: cs.primary, size: 26),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${item.category} • Rate: €${item.dailyRate.toStringAsFixed(0)}/day • Stock: ${item.availableStock}/${item.totalStock}${isAdmin ? " • Cost: €${item.purchaseCost.toStringAsFixed(0)}" : ""}',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Employee in Admin lahko označita opremo kot "V servisu"
                        FilterChip(
                          label: Text(
                            item.underMaintenance
                                ? 'In Maintenance'
                                : 'Operational',
                          ),
                          selected: item.underMaintenance,
                          onSelected: (_) =>
                              _data.toggleItemMaintenance(item.id),
                        ),
                        // Samo Admin lahko izbriše artikel iz kataloga
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Delete Equipment (Admin Only)',
                            onPressed: () => _data.deleteItem(item.id),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
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
  }

  void _showAddItemDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Cameras');
    final descCtrl = TextEditingController();
    final rateCtrl = TextEditingController(text: '65');
    final costCtrl = TextEditingController(text: '2200');
    final stockCtrl = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Equipment to Catalog (Admin)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Equipment Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: rateCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Daily Rate (€)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: costCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Purchase Cost (€ for ROI)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Stock'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                _data.addItem(
                  name: nameCtrl.text,
                  category: catCtrl.text,
                  description: descCtrl.text.isEmpty
                      ? 'Professional broadcast rental equipment.'
                      : descCtrl.text,
                  dailyRate: double.tryParse(rateCtrl.text) ?? 65.0,
                  purchaseCost: double.tryParse(costCtrl.text) ?? 2200.0,
                  totalStock: int.tryParse(stockCtrl.text) ?? 1,
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // TAB 3: ANIMIRANI VIZUALNI ROI GRAF (ADMIN ONLY)
  // ===========================================================================
  Widget _buildRoiGraphTab(ColorScheme cs) {
    final items = _selectedRoiCategory == 'All'
        ? _data.items
        : _data.items
            .where((i) => i.category == _selectedRoiCategory)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Finančne KPI kartice
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpiBox(
                cs,
                'Total Revenue Realized',
                '€${_data.totalRealizedRevenue.toStringAsFixed(0)}',
                'From verified rental invoices',
                const Color(0xFF10B981),
              ),
              _buildKpiBox(
                cs,
                'Equipment Unit Cost Basis',
                '€${_data.totalUnitCostBasis.toStringAsFixed(0)}',
                'Purchase cost of catalog models',
                const Color(0xFF6366F1),
              ),
              _buildKpiBox(
                cs,
                'Portfolio Net ROI',
                '${_data.overallRoiPercentage >= 0 ? "+" : ""}${_data.overallRoiPercentage.toStringAsFixed(1)}%',
                'Cost Recovery: ${_data.overallCostRecoveryPercentage.toStringAsFixed(1)}%',
                cs.primary,
              ),
              _buildKpiBox(
                cs,
                'Pending Receivables',
                '€${_data.pendingReceivables.toStringAsFixed(0)}',
                'Unpaid / awaiting verification',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 2. Kartica z animiranim ROI Grafom
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Equipment ROI & Cost Recovery Graph',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Animated comparison: Purchase Cost (€) vs. Generated Revenue (€) & Net ROI %',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Cost vs Revenue (€)'),
                          icon: Icon(Icons.bar_chart_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Recovery %'),
                          icon: Icon(Icons.percent_rounded, size: 16),
                        ),
                      ],
                      selected: {_showBreakEvenMode},
                      onSelectionChanged: (s) =>
                          setState(() => _showBreakEvenMode = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Legenda grafa
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _buildLegendDot(
                        cs, const Color(0xFF6366F1), 'Purchase Cost (€)'),
                    _buildLegendDot(cs, const Color(0xFF10B981),
                        'Revenue (Profitable > 100% Cost)'),
                    _buildLegendDot(
                        cs, cs.primary, 'Revenue (In Recovery < 100% Cost)'),
                  ],
                ),
                const SizedBox(height: 16),
                // Kategorije za filtriranje grafa
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _data.categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: _selectedRoiCategory == cat,
                          onSelected: (_) =>
                              setState(() => _selectedRoiCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Gladko animiran izris grafa ob vsaki spremembi filtra ali načina
                TweenAnimationBuilder<double>(
                  key: ValueKey(
                      'chart_${_selectedRoiCategory}_$_showBreakEvenMode'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, _) {
                    return SizedBox(
                      height: 330,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _RoiBarChartPainter(
                          items: items,
                          animationProgress: progress,
                          percentageMode: _showBreakEvenMode,
                          textColor: cs.onSurface,
                          mutedTextColor: cs.onSurfaceVariant,
                          gridColor: cs.outlineVariant,
                          primaryColor: cs.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Podrobna tabela donosnosti po artiklih
          Text(
            'Detailed ROI Breakdown by Equipment',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final isPositive = item.roiPercentage >= 0;
            final roiColor =
                isPositive ? const Color(0xFF10B981) : cs.primary;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: cs.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'Cost: €${item.purchaseCost.toStringAsFixed(0)} • Revenue: €${item.totalRevenueGenerated.toStringAsFixed(0)} • Net Profit: €${item.netProfit.toStringAsFixed(0)} (${item.totalRentalsCount} rentals)',
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
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: roiColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ROI: ${isPositive ? "+" : ""}${item.roiPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: roiColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendDot(ColorScheme cs, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildKpiBox(ColorScheme cs, String title, String value, String sub,
      Color accentColor) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 4: UPRAVLJANJE UPORABNIKOV IN VLOG (ADMIN ONLY)
  // ===========================================================================
  Widget _buildUsersTab(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Directory & Role Permissions (Admin)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Promote/demote accounts or add new local test users.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _showAddUserDialog(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final u = _data.users[index];
              final isSelf = _data.currentUser?.id == u.id;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: cs.primary.withValues(alpha: 0.14),
                      child: Icon(Icons.person_rounded, color: cs.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${u.name}${isSelf ? " (You)" : ""}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            u.email,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<UserRole>(
                      value: u.role,
                      items: UserRole.values.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(r.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (newRole) {
                        if (newRole != null) {
                          _data.updateUserRole(u.id, newRole);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: isSelf
                          ? 'Cannot delete active session'
                          : 'Delete User',
                      onPressed: isSelf ? null : () => _data.deleteUser(u.id),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: isSelf
                            ? cs.onSurfaceVariant.withValues(alpha: 0.3)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: '1234');
    UserRole role = UserRole.customer;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Local User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<UserRole>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: UserRole.values
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (r) {
                      if (r != null) setDialogState(() => role = r);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                    _data.registerUser(
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      password: passCtrl.text,
                      role: role,
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Create User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // TAB 5: SYSTEM AUDIT LOG (ADMIN ONLY)
  // ===========================================================================
  Widget _buildAuditLogTab(ColorScheme cs) {
    final logs = _data.auditLogs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Security & Audit Log (Admin Only)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tracks all administrative and operational actions across the local workspace.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: cs.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.action} • by ${log.actorName} (${log.actorRole.name.toUpperCase()})',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.details,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// CustomPainter za izris animiranega ROI grafa, prilagojenega tako Light kot Dark temi.
class _RoiBarChartPainter extends CustomPainter {
  final List<Item> items;
  final double animationProgress;
  final bool percentageMode;
  final Color textColor;
  final Color mutedTextColor;
  final Color gridColor;
  final Color primaryColor;

  _RoiBarChartPainter({
    required this.items,
    required this.animationProgress,
    required this.percentageMode,
    required this.textColor,
    required this.mutedTextColor,
    required this.gridColor,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    const double leftPadding = 58;
    const double bottomPadding = 50;
    const double topPadding = 30;
    const double rightPadding = 16;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    double maxVal = percentageMode ? 150.0 : 1000.0;
    for (final item in items) {
      if (percentageMode) {
        maxVal = math.max(maxVal, item.costRecoveryPercentage);
      } else {
        maxVal = math.max(
          maxVal,
          math.max(item.purchaseCost, item.totalRevenueGenerated),
        );
      }
    }
    maxVal = maxVal * 1.15;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // 1. Vodoravne mrežne črte in oznake Y-osi
    const int gridSteps = 4;
    for (int i = 0; i <= gridSteps; i++) {
      final ratio = i / gridSteps;
      final y = topPadding + chartHeight * (1 - ratio);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final val = (maxVal * ratio).round();
      final label = percentageMode ? '$val%' : '€$val';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: mutedTextColor, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 8, y - tp.height / 2));
    }

    // 2. Animirani stolpci za vsak artikel
    final groupWidth = chartWidth / items.length;
    final barWidth = math.min(24.0, groupWidth * 0.28);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final groupCenterX = leftPadding + groupWidth * (i + 0.5);
      final isProfitable = item.totalRevenueGenerated >= item.purchaseCost;

      final costVal =
          percentageMode ? 100.0 : item.purchaseCost; // 100% je break-even baza
      final revVal = percentageMode
          ? item.costRecoveryPercentage
          : item.totalRevenueGenerated;

      final costHeight =
          (costVal / maxVal) * chartHeight * animationProgress;
      final revHeight =
          (revVal / maxVal) * chartHeight * animationProgress;

      final costRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          groupCenterX - barWidth - 2,
          topPadding + chartHeight - costHeight,
          barWidth,
          costHeight,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final revRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          groupCenterX + 2,
          topPadding + chartHeight - revHeight,
          barWidth,
          revHeight,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final costPaint = Paint()..color = const Color(0xFF6366F1);
      final revPaint = Paint()
        ..color = isProfitable ? const Color(0xFF10B981) : primaryColor;

      canvas.drawRRect(costRect, costPaint);
      canvas.drawRRect(revRect, revPaint);

      // Izpis ROI % nad stolpcem
      final roiText =
          '${item.roiPercentage >= 0 ? "+" : ""}${item.roiPercentage.toStringAsFixed(0)}%';
      final roiTp = TextPainter(
        text: TextSpan(
          text: roiText,
          style: TextStyle(
            color: isProfitable ? const Color(0xFF10B981) : primaryColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final highestY = topPadding +
          chartHeight -
          math.max(costHeight, revHeight) -
          roiTp.height -
          5;
      roiTp.paint(canvas, Offset(groupCenterX - roiTp.width / 2, highestY));

      // Ime artikla na X-osi
      final shortName = item.name.length > 11
          ? '${item.name.substring(0, 9)}…'
          : item.name;
      final nameTp = TextPainter(
        text: TextSpan(
          text: shortName,
          style: TextStyle(
            color: textColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      nameTp.paint(
        canvas,
        Offset(
          groupCenterX - nameTp.width / 2,
          topPadding + chartHeight + 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoiBarChartPainter oldDelegate) => true;
}