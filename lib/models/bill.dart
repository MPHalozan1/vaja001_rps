/// Statusi računa
enum BillStatus {
  unpaid, // Izdan račun, čaka na plačilo stranke
  pendingApproval, // Stranka kliknila Pay, čaka na potrditev osebja
  paid, // Potrjeno plačano (šteje v realiziran ROI)
  overdue, // Zamuda pri plačilu
  waived, // Odpisano s strani Administratorja
}

/// Model računa (Invoice), ki nastane ob odobritvi Ticketa
class Bill {
  final String id;
  final String borrowRequestId;
  final String userId;
  final String userName;
  final String itemName;
  final double amount;
  final double penaltyFee; // Morebitni strošek poškodbe ali zamude ob vračilu
  final DateTime issuedDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final BillStatus status;
  final String? approvedByStaffName;

  const Bill({
    required this.id,
    required this.borrowRequestId,
    required this.userId,
    required this.userName,
    required this.itemName,
    required this.amount,
    this.penaltyFee = 0.0,
    required this.issuedDate,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.approvedByStaffName,
  });

  double get totalAmount => amount + penaltyFee;

  bool get isPaid => status == BillStatus.paid;

  String get statusLabel {
    switch (status) {
      case BillStatus.unpaid:
        return 'Unpaid';
      case BillStatus.pendingApproval:
        return 'Verifying Payment';
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.overdue:
        return 'Overdue';
      case BillStatus.waived:
        return 'Waived (Admin)';
    }
  }

  Bill copyWith({
    String? id,
    String? borrowRequestId,
    String? userId,
    String? userName,
    String? itemName,
    double? amount,
    double? penaltyFee,
    DateTime? issuedDate,
    DateTime? dueDate,
    DateTime? paidDate,
    BillStatus? status,
    String? approvedByStaffName,
  }) {
    return Bill(
      id: id ?? this.id,
      borrowRequestId: borrowRequestId ?? this.borrowRequestId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      itemName: itemName ?? this.itemName,
      amount: amount ?? this.amount,
      penaltyFee: penaltyFee ?? this.penaltyFee,
      issuedDate: issuedDate ?? this.issuedDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      approvedByStaffName: approvedByStaffName ?? this.approvedByStaffName,
    );
  }
}