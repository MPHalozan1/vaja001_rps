/// Statusi življenjskega cikla rezervacije (Ticketa)
enum BorrowStatus {
  pending, // Čaka na odobritev zaposlenega/admina
  approved, // Odobreno, oprema je pri stranki
  rejected, // Zavrnjeno s strani osebja
  returned, // Oprema vrnjena v skladišče
  cancelled, // Preklicano s strani stranke
}

/// Model za zahtevek za izposojo (Reservation Ticket)
class BorrowRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String itemId;
  final String itemName;
  final int quantity;
  final DateTime startDate;
  final DateTime endDate;
  final double dailyRate;
  final double discountPercent; // Popust prek promo kode (npr. 10% ali 20%)
  final BorrowStatus status;
  final DateTime createdAt;
  final String? handledByStaffName;
  final String? staffNote;
  final String? returnConditionNote;

  const BorrowRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.dailyRate,
    this.discountPercent = 0.0,
    required this.status,
    required this.createdAt,
    this.handledByStaffName,
    this.staffNote,
    this.returnConditionNote,
  });

  /// Število dni najema (najmanj 1 dan)
  int get durationDays {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  /// Končni znesek najema z upoštevanim morebitnim popustom
  double get totalCost {
    final gross = dailyRate * durationDays * quantity;
    final factor = (100.0 - discountPercent.clamp(0.0, 100.0)) / 100.0;
    return gross * factor;
  }

  String get statusLabel {
    switch (status) {
      case BorrowStatus.pending:
        return 'Pending Approval';
      case BorrowStatus.approved:
        return 'Approved (Active)';
      case BorrowStatus.rejected:
        return 'Rejected';
      case BorrowStatus.returned:
        return 'Returned';
      case BorrowStatus.cancelled:
        return 'Cancelled';
    }
  }

  BorrowRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? itemId,
    String? itemName,
    int? quantity,
    DateTime? startDate,
    DateTime? endDate,
    double? dailyRate,
    double? discountPercent,
    BorrowStatus? status,
    DateTime? createdAt,
    String? handledByStaffName,
    String? staffNote,
    String? returnConditionNote,
  }) {
    return BorrowRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyRate: dailyRate ?? this.dailyRate,
      discountPercent: discountPercent ?? this.discountPercent,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      handledByStaffName: handledByStaffName ?? this.handledByStaffName,
      staffNote: staffNote ?? this.staffNote,
      returnConditionNote: returnConditionNote ?? this.returnConditionNote,
    );
  }
}