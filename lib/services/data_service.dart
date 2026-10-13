import '../models/user.dart';
import '../models/item.dart';
import '../models/borrow_request.dart';
import '../models/bill.dart';
import 'package:flutter/material.dart';

class DataService extends ChangeNotifier {
  List<User> users = [];
  List<Item> items = [];
  List<BorrowRequest> borrowRequests = [];
  List<Bill> bills = [];

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  DataService() {
    _seedData();
  }

  void _seedData() {
    // 1 Admin
    users.add(User(id: 'u1', name: 'Alice Admin', role: UserRole.admin, contactInfo: 'alice@admin.com'));
    // 2 Employees
    users.add(User(id: 'u2', name: 'Bob Employee', role: UserRole.employee, contactInfo: 'bob@staff.com'));
    users.add(User(id: 'u3', name: 'Charlie Employee', role: UserRole.employee, contactInfo: 'charlie@staff.com'));
    // Customers
    users.add(User(id: 'u4', name: 'David Smith', role: UserRole.customer, contactInfo: 'david@test.com'));
    users.add(User(id: 'u5', name: 'Eva Johnson', role: UserRole.customer, contactInfo: 'eva@test.com'));
    users.add(User(id: 'u6', name: 'Frank Williams', role: UserRole.customer, contactInfo: 'frank@test.com'));

    // --- Items ---
    // IT & Computers
    items.add(Item(id: 'i1', name: 'MacBook Pro 16"', category: 'IT & Computers', subcategory: 'Laptops', totalQuantity: 3, availableQuantity: 3, pricePerDay: 50.0, specs: {'Processor': 'M2 Max', 'RAM': '32GB', 'Storage': '1TB SSD'}));
    items.add(Item(id: 'i2', name: 'Dell XPS 15', category: 'IT & Computers', subcategory: 'Laptops', totalQuantity: 2, availableQuantity: 2, pricePerDay: 40.0, specs: {'Processor': 'Intel i9', 'RAM': '64GB', 'Storage': '2TB SSD', 'Display': '4K OLED'}));
    items.add(Item(id: 'i3', name: 'iPad Pro 12.9"', category: 'IT & Computers', subcategory: 'Tablets', totalQuantity: 4, availableQuantity: 4, pricePerDay: 25.0, specs: {'Chip': 'M2', 'Storage': '256GB', 'Accessory': 'Apple Pencil 2'}));
    items.add(Item(id: 'i4', name: 'Lenovo ThinkPad X1', category: 'IT & Computers', subcategory: 'Laptops', totalQuantity: 3, availableQuantity: 3, pricePerDay: 35.0, specs: {'Processor': 'Intel i7', 'RAM': '16GB', 'Weight': '1.13 kg'}));

    // Photo & Video
    items.add(Item(id: 'i5', name: 'Sony A7S III', category: 'Photo & Video', subcategory: 'Cameras', totalQuantity: 2, availableQuantity: 2, pricePerDay: 80.0, specs: {'Resolution': '12.1MP', 'Video': '4K 120p', 'Mount': 'Sony E'}));
    items.add(Item(id: 'i6', name: 'Canon EOS R5', category: 'Photo & Video', subcategory: 'Cameras', totalQuantity: 1, availableQuantity: 1, pricePerDay: 90.0, specs: {'Resolution': '45MP', 'Video': '8K RAW', 'Stabilization': 'IBIS'}));
    items.add(Item(id: 'i7', name: 'DJI Ronin RS 3 Pro', category: 'Photo & Video', subcategory: 'Stabilizers', totalQuantity: 3, availableQuantity: 3, pricePerDay: 40.0, specs: {'Payload': '4.5 kg', 'Material': 'Carbon Fiber', 'Battery': '12h'}));
    items.add(Item(id: 'i8', name: 'Aputure 120d II', category: 'Photo & Video', subcategory: 'Lighting', totalQuantity: 4, availableQuantity: 4, pricePerDay: 25.0, specs: {'Type': 'LED', 'Output': '135,000 lux', 'Mount': 'Bowens'}));

    // Tools & Home
    items.add(Item(id: 'i9', name: 'Kärcher K5 Pressure Washer', category: 'Tools & Home', subcategory: 'Cleaning', totalQuantity: 3, availableQuantity: 3, pricePerDay: 20.0, specs: {'Pressure': '145 bar', 'Flow Rate': '500 l/h', 'Power': '2100W'}));
    items.add(Item(id: 'i10', name: 'Bosch Professional Hammer Drill', category: 'Tools & Home', subcategory: 'Power Tools', totalQuantity: 5, availableQuantity: 5, pricePerDay: 15.0, specs: {'Power': '880W', 'Impact Energy': '3.2 J', 'Chuck': 'SDS-plus'}));
    items.add(Item(id: 'i11', name: 'Makita Circular Saw', category: 'Tools & Home', subcategory: 'Power Tools', totalQuantity: 2, availableQuantity: 2, pricePerDay: 18.0, specs: {'Blade': '190mm', 'Cut Depth': '66mm', 'Speed': '5200 rpm'}));

    // Audio
    items.add(Item(id: 'i12', name: 'Rode NTG4+ Shotgun Mic', category: 'Audio', subcategory: 'Microphones', totalQuantity: 4, availableQuantity: 4, pricePerDay: 15.0, specs: {'Type': 'Condenser', 'Pattern': 'Supercardioid', 'Battery': 'Internal 150h'}));
    items.add(Item(id: 'i13', name: 'Zoom H6 Recorder', category: 'Audio', subcategory: 'Recorders', totalQuantity: 2, availableQuantity: 2, pricePerDay: 20.0, specs: {'Tracks': '6', 'Resolution': '24-bit/96kHz', 'Inputs': '4x XLR/TRS'}));
    items.add(Item(id: 'i14', name: 'Sennheiser G4 Wireless', category: 'Audio', subcategory: 'Wireless', totalQuantity: 3, availableQuantity: 3, pricePerDay: 30.0, specs: {'Range': '100m', 'Band': 'UHF', 'Mic': 'ME2-II Lav'}));

    // Gaming
    items.add(Item(id: 'i15', name: 'PlayStation 5', category: 'Gaming', subcategory: 'Consoles', totalQuantity: 3, availableQuantity: 3, pricePerDay: 25.0, specs: {'Storage': '825GB SSD', 'Output': '4K 120Hz', 'Controllers': '2x DualSense'}));
    items.add(Item(id: 'i16', name: 'Xbox Series X', category: 'Gaming', subcategory: 'Consoles', totalQuantity: 2, availableQuantity: 2, pricePerDay: 25.0, specs: {'Storage': '1TB SSD', 'Output': '4K 120Hz', 'Controllers': '2x Wireless'}));
    items.add(Item(id: 'i17', name: 'Meta Quest 3', category: 'Gaming', subcategory: 'VR', totalQuantity: 4, availableQuantity: 4, pricePerDay: 30.0, specs: {'Storage': '512GB', 'Display': '4K+ Infinite', 'Tracking': 'Inside-out'}));


    // --- Pre-existing Reservations (for calendar testing) ---
    final now = DateTime.now();
    // i1 (MacBook Pro) reserved by David (u4) for next 3 days
    borrowRequests.add(BorrowRequest(id: 'br1', userId: 'u4', itemId: 'i1', startDate: now.add(const Duration(days: 1)), returnDate: now.add(const Duration(days: 3))));
    bills.add(Bill(id: 'b1', customerId: 'u4', employeeId: 'u2', amount: 150.0, status: BillStatus.approved));

    // i5 (Sony A7S III) reserved by Eva (u5) for next weekend (assuming starting +5 days)
    borrowRequests.add(BorrowRequest(id: 'br2', userId: 'u5', itemId: 'i5', startDate: now.add(const Duration(days: 5)), returnDate: now.add(const Duration(days: 7))));
    bills.add(Bill(id: 'b2', customerId: 'u5', employeeId: 'u2', amount: 240.0, status: BillStatus.pendingAdminApproval));

    // i15 (PS5) reserved by Frank (u6) currently active (started yesterday)
    borrowRequests.add(BorrowRequest(id: 'br3', userId: 'u6', itemId: 'i15', startDate: now.subtract(const Duration(days: 1)), returnDate: now.add(const Duration(days: 2))));
    bills.add(Bill(id: 'b3', customerId: 'u6', employeeId: 'u3', amount: 100.0, status: BillStatus.approved));
  }

  // --- User Management ---
  void registerNewUser(User currentUser, String name, UserRole role) {
    if (currentUser.role != UserRole.admin) {
      throw Exception('Unauthorized: Only Admins can add users.');
    }
    if (role == UserRole.customer) {
      throw Exception('Unauthorized: Admins can only add Employees, not Customers.');
    }
    final newId = 'u${users.length + 1}'; // Simple ID generation
    users.add(User(id: newId, name: name, role: role));
    notifyListeners();
  }

  User selfRegisterCustomer(String name, String contactInfo) {
    final newId = 'u${users.length + 1}'; // Simple ID generation
    final newUser = User(id: newId, name: name, role: UserRole.customer, contactInfo: contactInfo);
    users.add(newUser);
    notifyListeners();
    return newUser;
  }

  void updateUserProfile(User currentUser, String name, String contactInfo) {
    final index = users.indexWhere((user) => user.id == currentUser.id);
    if (index != -1) {
      users[index] = users[index].copyWith(name: name, contactInfo: contactInfo);
      notifyListeners();
    }
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

  /// Checks if an item has available stock for a given date range.
  ///
  /// This iterates through all existing `BorrowRequest`s for the specific [itemId].
  /// It normalizes dates to the start of the day to ensure fair comparison.
  /// Overlap logic: Two periods [s1, e1] and [s2, e2] overlap if `max(s1, s2) <= min(e1, e2)`.
  /// If the number of overlapping reservations is equal to or greater than the
  /// item's `totalQuantity`, the item is unavailable for the requested period.
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

  /// Processes a self-service item reservation made by a Customer.
  ///
  /// Requires the [currentUser] to have a `UserRole.customer` role.
  /// Validates the date logic (start date cannot be past, end date >= start date).
  /// Verifies item availability against the requested date range.
  /// Generates a new `BorrowRequest` upon successful validation.
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

  void createWalkInTicket(User currentUser, String customerId, String itemId, DateTime start, DateTime end) {
    if (currentUser.role != UserRole.employee) {
      throw Exception('Unauthorized: Only Employees can create walk-in tickets.');
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

    final customerExists = users.any((u) => u.id == customerId && u.role == UserRole.customer);
    if (!customerExists) {
      throw Exception("Error: Customer not found.");
    }

    final item = items.firstWhere((i) => i.id == itemId);

    final newId = 'br${borrowRequests.length + 1}';
    borrowRequests.add(BorrowRequest(
      id: newId,
      userId: customerId,
      itemId: itemId,
      startDate: start,
      returnDate: end,
    ));

    int days = end.difference(start).inDays + 1;
    double amount = days * item.pricePerDay;

    final newBillId = 'b${bills.length + 1}';
    bills.add(Bill(
      id: newBillId,
      customerId: customerId,
      employeeId: currentUser.id,
      amount: amount,
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
