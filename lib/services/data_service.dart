import '../models/user.dart';
import '../models/item.dart';
import '../models/borrow_request.dart';
import '../models/bill.dart';
import 'package:flutter/foundation.dart';

class DataService extends ChangeNotifier {
  List<User> users = [];
  List<Item> items = [];
  List<BorrowRequest> borrowRequests = [];
  List<Bill> bills = [];

  DataService() {
    _seedData();
  }

  void _seedData() {
    // Bills
    bills.add(Bill(id: 'b1', customerId: 'u4', employeeId: 'u2', amount: 150.0));
    bills.add(Bill(id: 'b2', customerId: 'u5', employeeId: 'u3', amount: 50.0));

    // 1 Admin
    users.add(User(id: 'u1', name: 'Alice Admin', role: UserRole.admin));

    // 2 Employees
    users.add(User(id: 'u2', name: 'Bob Employee', role: UserRole.employee));
    users.add(User(id: 'u3', name: 'Charlie Employee', role: UserRole.employee));

    // 5 Customers
    users.add(User(id: 'u4', name: 'David Smith', role: UserRole.customer));
    users.add(User(id: 'u5', name: 'Eva Johnson', role: UserRole.customer));
    users.add(User(id: 'u6', name: 'Frank Williams', role: UserRole.customer));
    users.add(User(id: 'u7', name: 'Grace Brown', role: UserRole.customer));
    users.add(User(id: 'u8', name: 'Henry Jones', role: UserRole.customer));

    // Items
    // IT
    items.add(Item(id: 'i1', name: 'MacBook Pro 16"', category: 'IT', subcategory: 'Laptops', totalQuantity: 3, availableQuantity: 3, pricePerDay: 50.0));
    items.add(Item(id: 'i2', name: 'Dell XPS 15', category: 'IT', subcategory: 'Laptops', totalQuantity: 2, availableQuantity: 2, pricePerDay: 40.0));
    items.add(Item(id: 'i3', name: 'iPad Pro', category: 'IT', subcategory: 'Tablets', totalQuantity: 4, availableQuantity: 4, pricePerDay: 25.0));

    // Household (Gospodinjstva)
    items.add(Item(id: 'i4', name: 'Kärcher Pressure Washer', category: 'Household', subcategory: 'Cleaning', totalQuantity: 2, availableQuantity: 2, pricePerDay: 15.0));
    items.add(Item(id: 'i5', name: 'Bosch Power Drill', category: 'Household', subcategory: 'Tools', totalQuantity: 5, availableQuantity: 5, pricePerDay: 10.0));

    // Audio/Video
    items.add(Item(id: 'i6', name: 'Sony A7III Camera', category: 'Audio/Video', subcategory: 'Cameras', totalQuantity: 2, availableQuantity: 2, pricePerDay: 60.0));
    items.add(Item(id: 'i7', name: 'Rode NTG4 Microphone', category: 'Audio/Video', subcategory: 'Audio', totalQuantity: 3, availableQuantity: 3, pricePerDay: 20.0));
    items.add(Item(id: 'i8', name: 'DJI Ronin Gimbal', category: 'Audio/Video', subcategory: 'Accessories', totalQuantity: 1, availableQuantity: 1, pricePerDay: 35.0));
  }

  // --- User Management ---
  void registerNewUser(User currentUser, String name, UserRole role) {
    if (currentUser.role != UserRole.admin) {
      throw Exception('Unauthorized: Only Admins can add users.');
    }
    final newId = 'u${users.length + 1}'; // Simple ID generation
    users.add(User(id: newId, name: name, role: role));
    notifyListeners();
  }

  void deleteUserAccount(User currentUser, String id) {
    if (currentUser.role != UserRole.admin) {
      throw Exception('Unauthorized: Only Admins can remove users.');
    }
    users.removeWhere((user) => user.id == id);
    notifyListeners();
  }

  void updateUserRole(User currentUser, String id, UserRole newRole) {
    if (currentUser.role != UserRole.admin) {
      throw Exception('Unauthorized: Only Admins can change user roles.');
    }
    final index = users.indexWhere((user) => user.id == id);
    if (index != -1) {
      final oldUser = users[index];
      users[index] = User(id: oldUser.id, name: oldUser.name, role: newRole, borrowedItemIds: oldUser.borrowedItemIds);
      notifyListeners();
    }
  }

  // --- Item Management ---
  void addInventoryItem(User currentUser, Item item) {
    if (currentUser.role != UserRole.admin && currentUser.role != UserRole.employee) {
      throw Exception('Unauthorized: Only Admins or Employees can add items.');
    }
    if (item.totalQuantity < 0) {
      throw Exception('Invalid item: Quantity cannot be negative.');
    }
    if (item.pricePerDay < 0) {
      throw Exception('Invalid item: Price cannot be negative.');
    }
    items.add(item);
    notifyListeners();
  }

  void removeInventoryItem(User currentUser, String id) {
    if (currentUser.role != UserRole.admin && currentUser.role != UserRole.employee) {
      throw Exception('Unauthorized: Only Admins or Employees can remove items.');
    }
    items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // --- Reservation Logic ---
  bool checkItemAvailability(String itemId, DateTime start, DateTime end) {
    // Normalization to start of day for comparison
    final reqStart = DateTime(start.year, start.month, start.day);
    final reqEnd = DateTime(end.year, end.month, end.day);

    int reservedCount = 0;
    for (final req in borrowRequests.where((r) => r.itemId == itemId)) {
      final existingStart = DateTime(req.startDate.year, req.startDate.month, req.startDate.day);
      final existingEnd = DateTime(req.returnDate.year, req.returnDate.month, req.returnDate.day);

      // Check for overlap
      // Two periods [s1, e1] and [s2, e2] overlap if max(s1, s2) <= min(e1, e2)
      final maxStart = reqStart.isAfter(existingStart) ? reqStart : existingStart;
      final minEnd = reqEnd.isBefore(existingEnd) ? reqEnd : existingEnd;

      if (maxStart.isBefore(minEnd) || maxStart.isAtSameMomentAs(minEnd)) {
        reservedCount++;
      }
    }

    final item = items.firstWhere((i) => i.id == itemId);
    return reservedCount < item.totalQuantity;
  }

  List<BorrowRequest> getReservationsForItem(String itemId) {
    return borrowRequests.where((req) => req.itemId == itemId).toList();
  }

  void processItemReservation(User currentUser, String itemId, DateTime start, DateTime end) {
    if (currentUser.role != UserRole.customer) {
      throw Exception('Unauthorized: Only Customers can reserve items.');
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reqStart = DateTime(start.year, start.month, start.day);
    final reqEnd = DateTime(end.year, end.month, end.day);

    if (reqStart.isBefore(today)) {
      throw Exception('Error: Start date cannot be in the past.');
    }
    if (reqEnd.isBefore(reqStart)) {
      throw Exception('Error: End date cannot be before start date.');
    }

    if (!checkItemAvailability(itemId, start, end)) {
      throw Exception('Error: Dates overlap or item not available.');
    }

    // Check if user is actually in system
    final userExists = users.any((u) => u.id == currentUser.id);
    if (!userExists) {
      throw Exception("Error: Unauthorized user.");
    }

    final newId = 'br${borrowRequests.length + 1}';
    borrowRequests.add(BorrowRequest(
      id: newId,
      userId: currentUser.id,
      itemId: itemId,
      startDate: start,
      returnDate: end,
    ));

    notifyListeners();
  }

  // --- Bill Management ---
  String approveEmployeeBill(User currentUser, String billId) {
    if (currentUser.role != UserRole.admin && currentUser.role != UserRole.employee) {
      throw Exception('Unauthorized: Only Admins or Employees can approve bills.');
    }

    final index = bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      if (bills[index].status == BillStatus.pendingAdminApproval) {
        bills[index].status = BillStatus.approved;
        notifyListeners();
        return 'Bill approved successfully.';
      } else {
        throw Exception('Bill is not pending approval.');
      }
    }

    throw Exception('Bill not found.');
  }
}
