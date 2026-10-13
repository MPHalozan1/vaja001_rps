class BorrowRequest {
  final String id;
  final String userId;
  final String itemId;
  final DateTime startDate;
  final DateTime returnDate;
  final String? disclaimers;
  final double? penalties;
  final String location;
  final bool isReturned;

  BorrowRequest({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.startDate,
    required this.returnDate,
    this.disclaimers,
    this.penalties,
    this.location = 'Skladišče',
    this.isReturned = false,
  });
}
