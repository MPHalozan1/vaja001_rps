enum BillStatus { pendingAdminApproval, approved, paid, unpaid }

class Bill {
  final String id;
  final String customerId;
  final String employeeId;
  final double amount;
  BillStatus status;
  final String? borrowRequestId;

  Bill({
    required this.id,
    required this.customerId,
    required this.employeeId,
    required this.amount,
    this.status = BillStatus.pendingAdminApproval,
    this.borrowRequestId,
  });
}
