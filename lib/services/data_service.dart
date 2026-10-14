import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../models/borrow_request.dart';
import '../models/item.dart';
import '../models/user.dart';

/// Singleton servis, ki drži vse podatke v pomnilniku in obvešča UI ob vsaki spremembi.
/// Vključuje upravljanje teme (Light/Dark), avtentikacijo, katalog, tickete, račune in audit log.
class DataService extends ChangeNotifier {
  static final DataService instance = DataService._internal();
  factory DataService() => instance;

  DataService._internal() {
    _seedInitialData();
  }

  // Trenutna barvna tema aplikacije (privzeto Dark, s klikom preklopiš na Light)
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleThemeMode() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // Seznami podatkov v pomnilniku
  final List<User> _users = [];
  final List<Item> _items = [];
  final List<BorrowRequest> _borrowRequests = [];
  final List<Bill> _bills = [];
  final List<AppNotification> _notifications = [];
  final List<AuditLogEntry> _auditLogs = [];
  final Map<String, Set<String>> _userFavorites = {};

  User? _currentUser;

  // Javni bralni getterji
  User? get currentUser => _currentUser;
  List<User> get users => List.unmodifiable(_users);
  List<Item> get items => List.unmodifiable(_items);
  List<BorrowRequest> get borrowRequests => List.unmodifiable(_borrowRequests);
  List<Bill> get bills => List.unmodifiable(_bills);
  List<AuditLogEntry> get auditLogs => List.unmodifiable(_auditLogs);

  List<String> get categories {
    final set = _items.map((e) => e.category).toSet().toList()..sort();
    return ['All', ...set];
  }

  /// Bogat nabor začetnih (dummy) podatkov za testiranje vseh vlog in grafov
  void _seedInitialData() {
    final now = DateTime.now();

    // 1. Začetni uporabniki (1 Admin, 2 Employeeja, 3 Stranke)
    _users.addAll([
      User(
        id: 'usr-admin',
        name: 'Miha Plajnšek (Admin)',
        email: 'admin@rps.local',
        password: 'admin',
        role: UserRole.admin,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      User(
        id: 'usr-emp1',
        name: 'Luka Novak (Employee)',
        email: 'luka@rps.local',
        password: 'emp',
        role: UserRole.employee,
        createdAt: now.subtract(const Duration(days: 85)),
      ),
      User(
        id: 'usr-emp2',
        name: 'Sara Vidmar (Employee)',
        email: 'sara@rps.local',
        password: 'emp',
        role: UserRole.employee,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      User(
        id: 'usr-cust1',
        name: 'Ana Kovač',
        email: 'ana@rps.local',
        password: 'user',
        role: UserRole.customer,
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      User(
        id: 'usr-cust2',
        name: 'Marko Zupan',
        email: 'marko@rps.local',
        password: 'user',
        role: UserRole.customer,
        createdAt: now.subtract(const Duration(days: 28)),
      ),
      User(
        id: 'usr-cust3',
        name: 'Nina Kralj',
        email: 'nina@rps.local',
        password: 'user',
        role: UserRole.customer,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ]);

    // 2. Bogat katalog 12 profesionalnih naprav v 6 kategorijah
    _items.addAll([
      const Item(
        id: 'itm-1',
        name: 'Sony FX3 Cinema Camera',
        category: 'Cameras',
        description:
            'Full-frame cinema line camera with 4K 120p recording, XLR top handle unit, and dual CFexpress Type A slots.',
        dailyRate: 85.0,
        purchaseCost: 3900.0,
        totalStock: 5,
        availableStock: 3,
        icon: Icons.videocam_rounded,
        specs: {
          'Sensor': 'Full-Frame CMOS',
          'Resolution': '4K 120fps 10-bit',
          'Dynamic Range': '15+ Stops S-Log3',
          'Mount': 'Sony E-Mount',
        },
        totalRentalsCount: 62,
        totalRevenueGenerated: 5270.0,
      ),
      const Item(
        id: 'itm-2',
        name: 'RED Komodo 6K Production Pack',
        category: 'Cameras',
        description:
            'Compact Super 35 global shutter cinema camera with RF mount, Wing Grip, and 2x 512GB RED PRO CFast cards.',
        dailyRate: 135.0,
        purchaseCost: 6400.0,
        totalStock: 3,
        availableStock: 2,
        icon: Icons.camera_roll_rounded,
        specs: {
          'Sensor': '6K Global Shutter',
          'Codec': 'REDCODE RAW',
          'Weight': '0.95 kg Body',
          'Mount': 'Canon RF / EF Adapter',
        },
        totalRentalsCount: 55,
        totalRevenueGenerated: 7425.0,
      ),
      const Item(
        id: 'itm-3',
        name: 'DJI Mavic 3 Pro Cine',
        category: 'Drones',
        description:
            'Tri-camera flagship drone with Hasselblad 4/3 CMOS camera, Apple ProRes 422 HQ, and 43-min flight time.',
        dailyRate: 70.0,
        purchaseCost: 2800.0,
        totalStock: 4,
        availableStock: 3,
        icon: Icons.flight_takeoff_rounded,
        specs: {
          'Main Camera': '4/3 CMOS Hasselblad',
          'Internal SSD': '1TB High-Speed',
          'Flight Time': '43 minutes',
          'Range': '15 km O3+',
        },
        totalRentalsCount: 48,
        totalRevenueGenerated: 3360.0,
      ),
      const Item(
        id: 'itm-4',
        name: 'DJI Inspire 3 X9-8K Air',
        category: 'Drones',
        description:
            'Full-frame 8K CinemaDNG and ProRes RAW aerial system with dual RC Plus controllers and RTK precision module.',
        dailyRate: 210.0,
        purchaseCost: 11500.0,
        totalStock: 2,
        availableStock: 2,
        icon: Icons.airplanemode_active_rounded,
        specs: {
          'Camera': 'Zenmuse X9-8K Air',
          'Max Speed': '94 km/h',
          'Control': 'Dual Operator RC Plus',
          'Positioning': 'Centimeter-Level RTK',
        },
        totalRentalsCount: 42,
        totalRevenueGenerated: 8820.0,
      ),
      const Item(
        id: 'itm-5',
        name: 'Aputure 600d Pro LED Kit',
        category: 'Lighting',
        description:
            '600W daylight-balanced Bowens mount point-source LED with weather-resistant control box and F10 Fresnel.',
        dailyRate: 45.0,
        purchaseCost: 1650.0,
        totalStock: 6,
        availableStock: 5,
        icon: Icons.wb_incandescent_rounded,
        specs: {
          'Power': '600W Output',
          'Color Temp': '5600K Daylight',
          'Mount': 'Universal Bowens',
          'Control': 'Sidus Link / DMX',
        },
        totalRentalsCount: 52,
        totalRevenueGenerated: 2340.0,
      ),
      const Item(
        id: 'itm-6',
        name: 'ARRI SkyPanel S60-C Softlight',
        category: 'Lighting',
        description:
            'Industry-standard tunable RGB+W LED softlight with full hue and saturation control and heavy-duty stand.',
        dailyRate: 90.0,
        purchaseCost: 4800.0,
        totalStock: 3,
        availableStock: 3,
        icon: Icons.light_mode_rounded,
        specs: {
          'CCT Range': '2,800K - 10,000K',
          'CRI / TLCI': '95 / 91',
          'Dimming': '0 - 100% Continuous',
          'DMX': '5-Pin In/Out + EtherCon',
        },
        totalRentalsCount: 61,
        totalRevenueGenerated: 5490.0,
      ),
      const Item(
        id: 'itm-7',
        name: 'Sound Devices MixPre-6 II',
        category: 'Audio',
        description:
            '32-bit float portable audio recorder and USB interface with ultra-low-noise Kashmir microphone preamps.',
        dailyRate: 35.0,
        purchaseCost: 1100.0,
        totalStock: 5,
        availableStock: 4,
        icon: Icons.graphic_eq_rounded,
        specs: {
          'Bit Depth': '32-bit Float / 192kHz',
          'Inputs': '4x XLR/TRS Combo',
          'Timecode': 'Internal Generator',
          'Power': 'USB-C / L-Mount',
        },
        totalRentalsCount: 38,
        totalRevenueGenerated: 1330.0,
      ),
      const Item(
        id: 'itm-8',
        name: 'Sennheiser MKH 416 Boom Kit',
        category: 'Audio',
        description:
            'Directional studio shotgun condenser microphone with Rycote blimp windshield and 3.5m carbon boom pole.',
        dailyRate: 28.0,
        purchaseCost: 980.0,
        totalStock: 6,
        availableStock: 6,
        icon: Icons.mic_external_on_rounded,
        specs: {
          'Pattern': 'Supercardioid / Lobar',
          'Power': '48V Phantom',
          'Boom Pole': '3.5m Carbon Fiber',
          'Mount': 'Rycote Lyre Shock',
        },
        totalRentalsCount: 44,
        totalRevenueGenerated: 1232.0,
      ),
      const Item(
        id: 'itm-9',
        name: 'DJI RS 4 Pro Gimbal Stabilizer',
        category: 'Stabilizers',
        description:
            'Carbon fiber 3-axis motorized gimbal with 4.5kg payload capacity and LiDAR autofocus system.',
        dailyRate: 32.0,
        purchaseCost: 950.0,
        totalStock: 5,
        availableStock: 4,
        icon: Icons.center_focus_strong_rounded,
        specs: {
          'Payload': '4.5 kg (10 lbs)',
          'Arms': 'Carbon Fiber',
          'Battery': '29 hr BG70 Grip',
          'Focus': 'LiDAR Rangefinder',
        },
        totalRentalsCount: 45,
        totalRevenueGenerated: 1440.0,
      ),
      const Item(
        id: 'itm-10',
        name: 'Tilta Float Handheld Support System',
        category: 'Stabilizers',
        description:
            'Spring-loaded support vest and carbon fiber post designed for extended cinema gimbal operation.',
        dailyRate: 48.0,
        purchaseCost: 1350.0,
        totalStock: 3,
        availableStock: 3,
        icon: Icons.accessibility_new_rounded,
        specs: {
          'Max Load': '10 kg',
          'Power': 'Dual V-Mount Pass-Thru',
          'Material': 'Aluminum & Carbon',
          'Compatibility': 'RS 3 / RS 4 Pro',
        },
        totalRentalsCount: 22,
        totalRevenueGenerated: 1056.0,
      ),
      const Item(
        id: 'itm-11',
        name: 'Threadripper 7970X Render & DIT Node',
        category: 'Workstations',
        description:
            'High-performance Linux/Windows workstation with 32-core Threadripper, Dual RTX 4090, and 10GbE networking.',
        dailyRate: 115.0,
        purchaseCost: 5600.0,
        totalStock: 2,
        availableStock: 1,
        icon: Icons.computer_rounded,
        specs: {
          'CPU': '32-Core TR 7970X',
          'RAM': '128GB ECC DDR5',
          'Storage': '8TB Gen5 NVMe RAID',
          'Network': 'Dual 10GbE SFP+',
        },
        totalRentalsCount: 54,
        totalRevenueGenerated: 6210.0,
      ),
      const Item(
        id: 'itm-12',
        name: 'Blackmagic ATEM Television Studio HD8',
        category: 'Workstations',
        description:
            'Live production switcher with integrated broadcast control panel, 8x 3G-SDI inputs, and hardware streaming.',
        dailyRate: 75.0,
        purchaseCost: 2950.0,
        totalStock: 3,
        availableStock: 3,
        icon: Icons.tune_rounded,
        specs: {
          'Inputs': '8x 3G-SDI Re-sync',
          'Multiview': 'SDI & HDMI Outputs',
          'Audio Mixer': 'Fairlight 58-Channel',
          'Streaming': 'Built-in RTMP Engine',
        },
        totalRentalsCount: 41,
        totalRevenueGenerated: 3075.0,
      ),
    ]);

    // 3. Začetni Ticketi (v vseh stanjih za takojšnje testiranje)
    _borrowRequests.addAll([
      BorrowRequest(
        id: 'TCK-1006',
        userId: 'usr-cust1',
        userName: 'Ana Kovač',
        userEmail: 'ana@rps.local',
        itemId: 'itm-1',
        itemName: 'Sony FX3 Cinema Camera',
        quantity: 1,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 4)),
        dailyRate: 85.0,
        status: BorrowStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        staffNote: 'Commercial shoot in Maribor, need V-Mount plate if possible.',
      ),
      BorrowRequest(
        id: 'TCK-1005',
        userId: 'usr-cust2',
        userName: 'Marko Zupan',
        userEmail: 'marko@rps.local',
        itemId: 'itm-4',
        itemName: 'DJI Inspire 3 X9-8K Air',
        quantity: 1,
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        dailyRate: 210.0,
        discountPercent: 10.0,
        status: BorrowStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
        staffNote: 'Promo RPS10 applied. Certified A2 drone pilot.',
      ),
      BorrowRequest(
        id: 'TCK-1004',
        userId: 'usr-cust3',
        userName: 'Nina Kralj',
        userEmail: 'nina@rps.local',
        itemId: 'itm-5',
        itemName: 'Aputure 600d Pro LED Kit',
        quantity: 2,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 3)),
        dailyRate: 45.0,
        status: BorrowStatus.pending,
        createdAt: now.subtract(const Duration(hours: 7)),
        staffNote: 'Studio interview lighting setup.',
      ),
      BorrowRequest(
        id: 'TCK-1003',
        userId: 'usr-cust1',
        userName: 'Ana Kovač',
        userEmail: 'ana@rps.local',
        itemId: 'itm-3',
        itemName: 'DJI Mavic 3 Pro Cine',
        quantity: 1,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 3)),
        dailyRate: 70.0,
        status: BorrowStatus.approved,
        createdAt: now.subtract(const Duration(days: 3)),
        handledByStaffName: 'Luka Novak (Employee)',
        staffNote: 'Handed over with 3 batteries and ND filter set.',
      ),
      BorrowRequest(
        id: 'TCK-1002',
        userId: 'usr-cust2',
        userName: 'Marko Zupan',
        userEmail: 'marko@rps.local',
        itemId: 'itm-11',
        itemName: 'Threadripper 7970X Render & DIT Node',
        quantity: 1,
        startDate: now.subtract(const Duration(days: 4)),
        endDate: now.add(const Duration(days: 2)),
        dailyRate: 115.0,
        status: BorrowStatus.approved,
        createdAt: now.subtract(const Duration(days: 5)),
        handledByStaffName: 'Sara Vidmar (Employee)',
        staffNote: 'Pre-installed DaVinci Resolve Studio on Linux.',
      ),
      BorrowRequest(
        id: 'TCK-1001',
        userId: 'usr-cust3',
        userName: 'Nina Kralj',
        userEmail: 'nina@rps.local',
        itemId: 'itm-2',
        itemName: 'RED Komodo 6K Production Pack',
        quantity: 1,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 6)),
        dailyRate: 135.0,
        status: BorrowStatus.returned,
        createdAt: now.subtract(const Duration(days: 11)),
        handledByStaffName: 'Luka Novak (Employee)',
        returnConditionNote: 'Returned in spotless condition.',
      ),
    ]);

    // 4. Začetni računi (Bills)
    _bills.addAll([
      Bill(
        id: 'INV-2004',
        borrowRequestId: 'TCK-1003',
        userId: 'usr-cust1',
        userName: 'Ana Kovač',
        itemName: '1x DJI Mavic 3 Pro Cine (5d)',
        amount: 350.0,
        issuedDate: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 6)),
        status: BillStatus.pendingApproval,
      ),
      Bill(
        id: 'INV-2003',
        borrowRequestId: 'TCK-1002',
        userId: 'usr-cust2',
        userName: 'Marko Zupan',
        itemName: '1x Threadripper 7970X Render & DIT Node (6d)',
        amount: 690.0,
        issuedDate: now.subtract(const Duration(days: 4)),
        dueDate: now.add(const Duration(days: 4)),
        status: BillStatus.unpaid,
      ),
      Bill(
        id: 'INV-2002',
        borrowRequestId: 'TCK-1001',
        userId: 'usr-cust3',
        userName: 'Nina Kralj',
        itemName: '1x RED Komodo 6K Production Pack (4d)',
        amount: 540.0,
        issuedDate: now.subtract(const Duration(days: 10)),
        dueDate: now.subtract(const Duration(days: 2)),
        paidDate: now.subtract(const Duration(days: 5)),
        status: BillStatus.paid,
        approvedByStaffName: 'Miha Plajnšek (Admin)',
      ),
      Bill(
        id: 'INV-2001',
        borrowRequestId: 'TCK-1000',
        userId: 'usr-cust2',
        userName: 'Marko Zupan',
        itemName: '2x Sennheiser MKH 416 Boom Kit (3d)',
        amount: 168.0,
        penaltyFee: 25.0,
        issuedDate: now.subtract(const Duration(days: 18)),
        dueDate: now.subtract(const Duration(days: 5)),
        status: BillStatus.overdue,
      ),
    ]);

    // 5. Začetni vnosi v System Audit Log (za Admina)
    _recordAudit(
      actorName: 'Miha Plajnšek (Admin)',
      actorRole: UserRole.admin,
      action: 'System Initialized',
      details: 'Loaded 12 catalog items, 6 accounts, and active rental queue.',
    );
    _recordAudit(
      actorName: 'Luka Novak (Employee)',
      actorRole: UserRole.employee,
      action: 'Ticket Approved (#TCK-1003)',
      details: 'Approved DJI Mavic 3 Pro Cine for Ana Kovač.',
    );

    // 6. Začetna obvestila
    _addNotification(
      userId: 'STAFF',
      title: '3 Pending Tickets in Queue',
      message: 'Ana, Marko, and Nina have open reservation tickets awaiting approval.',
    );
  }

  // ===========================================================================
  // DNEVNIK DOGODKOV (AUDIT LOG - SAMO ZA ADMINA)
  // ===========================================================================

  void _recordAudit({
    String? actorName,
    UserRole? actorRole,
    required String action,
    required String details,
  }) {
    final name = actorName ?? _currentUser?.name ?? 'System';
    final role = actorRole ?? _currentUser?.role ?? UserRole.admin;
    _auditLogs.insert(
      0,
      AuditLogEntry(
        id: 'LOG-${1000 + _auditLogs.length + 1}',
        actorName: name,
        actorRole: role,
        action: action,
        details: details,
        timestamp: DateTime.now(),
      ),
    );
  }

  // ===========================================================================
  // AVTENTIKACIJA IN UPRAVLJANJE UPORABNIKOV
  // ===========================================================================

  User? signIn(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final user = _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == normalizedEmail && u.password == password,
      );
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (_) {
      return null;
    }
  }

  void quickSignIn(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  /// Registracija novega uporabnika (v testiranju ali prek Admin plošče)
  User registerUser({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.customer,
    bool autoSignIn = false,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final exists = _users.any((u) => u.email.toLowerCase() == normalizedEmail);
    if (exists) {
      throw Exception('User with email $email already exists.');
    }

    final newUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      role: role,
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    if (autoSignIn) {
      _currentUser = newUser;
    }

    _recordAudit(
      actorName: newUser.name,
      actorRole: newUser.role,
      action: 'User Account Created',
      details: 'Registered ${newUser.email} with role ${newUser.roleLabel}.',
    );

    _addNotification(
      userId: 'STAFF',
      title: 'New User Registered',
      message: '${newUser.name} (${newUser.roleLabel}) joined RPS Hub.',
    );

    notifyListeners();
    return newUser;
  }

  /// Sprememba vloge uporabnika (dovoljeno SAMO Administratorju)
  void updateUserRole(String userId, UserRole newRole) {
    if (_currentUser?.isAdmin != true) {
      throw Exception('Only Administrators can modify user roles.');
    }
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;

    final oldRole = _users[idx].roleLabel;
    _users[idx] = _users[idx].copyWith(role: newRole);
    if (_currentUser?.id == userId) {
      _currentUser = _users[idx];
    }

    _recordAudit(
      action: 'User Role Updated',
      details:
          'Changed ${_users[idx].name} from $oldRole to ${_users[idx].roleLabel}.',
    );
    notifyListeners();
  }

  /// Izbris uporabnika (dovoljeno SAMO Administratorju, ne more izbrisati samega sebe)
  bool deleteUser(String userId) {
    if (_currentUser?.isAdmin != true) return false;
    if (_currentUser?.id == userId) return false;

    final target = _users.where((u) => u.id == userId).firstOrNull;
    if (target == null) return false;

    _users.removeWhere((u) => u.id == userId);
    _recordAudit(
      action: 'User Deleted',
      details: 'Removed account ${target.name} (${target.email}).',
    );
    notifyListeners();
    return true;
  }

  // ===========================================================================
  // PRILJUBLJENI IZDELKI (FAVORITES / WISHLIST)
  // ===========================================================================

  bool isFavorite(String itemId) {
    final uid = _currentUser?.id;
    if (uid == null) return false;
    return _userFavorites[uid]?.contains(itemId) ?? false;
  }

  void toggleFavorite(String itemId) {
    final uid = _currentUser?.id;
    if (uid == null) return;
    final set = _userFavorites.putIfAbsent(uid, () => <String>{});
    if (set.contains(itemId)) {
      set.remove(itemId);
    } else {
      set.add(itemId);
    }
    notifyListeners();
  }

  // ===========================================================================
  // UPRAVLJANJE INVENTARJA (LOČENE PRAVICE ADMIN VS EMPLOYEE)
  // ===========================================================================

  Item? getItemById(String itemId) {
    try {
      return _items.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

  /// Dodajanje novega izdelka v katalog (dovoljeno SAMO Administratorju)
  void addItem({
    required String name,
    required String category,
    required String description,
    required double dailyRate,
    required double purchaseCost,
    required int totalStock,
    IconData icon = Icons.devices_other_rounded,
    Map<String, String> specs = const {},
  }) {
    if (_currentUser?.isAdmin != true) {
      throw Exception('Only Administrators can add new catalog equipment.');
    }

    final newItem = Item(
      id: 'itm-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      category: category.trim(),
      description: description.trim(),
      dailyRate: dailyRate,
      purchaseCost: purchaseCost,
      totalStock: totalStock,
      availableStock: totalStock,
      icon: icon,
      specs: specs.isEmpty
          ? const {'Grade': 'Broadcast Pro', 'Warranty': 'RPS Verified'}
          : specs,
    );
    _items.insert(0, newItem);

    _recordAudit(
      action: 'Catalog Item Added',
      details:
          'Added ${newItem.name} (€${dailyRate.toStringAsFixed(0)}/day, Cost: €${purchaseCost.toStringAsFixed(0)}).',
    );
    notifyListeners();
  }

  /// Urejanje obstoječega izdelka
  void updateItem(Item updatedItem) {
    final idx = _items.indexWhere((i) => i.id == updatedItem.id);
    if (idx == -1) return;
    _items[idx] = updatedItem;
    _recordAudit(
      action: 'Inventory Item Updated',
      details:
          'Updated ${updatedItem.name} (Available: ${updatedItem.availableStock}/${updatedItem.totalStock}).',
    );
    notifyListeners();
  }

  /// Employee ali Admin lahko preklopi status servisa (Maintenance Mode)
  void toggleItemMaintenance(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final item = _items[idx];
    final nextState = !item.underMaintenance;
    _items[idx] = item.copyWith(underMaintenance: nextState);

    _recordAudit(
      action: nextState ? 'Marked Under Maintenance' : 'Restored from Service',
      details: '${item.name} maintenance status set to $nextState.',
    );
    notifyListeners();
  }

  /// Brisanje izdelka iz kataloga (dovoljeno SAMO Administratorju)
  void deleteItem(String itemId) {
    if (_currentUser?.isAdmin != true) {
      throw Exception('Only Administrators can delete catalog equipment.');
    }
    final target = getItemById(itemId);
    _items.removeWhere((i) => i.id == itemId);
    if (target != null) {
      _recordAudit(
        action: 'Catalog Item Deleted',
        details: 'Removed ${target.name} from inventory.',
      );
    }
    notifyListeners();
  }

  // ===========================================================================
  // REZERVACIJE / TICKETI (BORROW REQUESTS WORKFLOW)
  // ===========================================================================

  List<BorrowRequest> getRequestsForUser(String userId) {
    return _borrowRequests.where((r) => r.userId == userId).toList();
  }

  List<BorrowRequest> get pendingTickets {
    return _borrowRequests
        .where((r) => r.status == BorrowStatus.pending)
        .toList();
  }

  /// Preveri veljavnost promo kode in vrne odstotek popusta
  double evaluatePromoCode(String? code) {
    if (code == null || code.trim().isEmpty) return 0.0;
    switch (code.trim().toUpperCase()) {
      case 'RPS10':
        return 10.0;
      case 'STUDENT20':
      case 'VIP20':
        return 20.0;
      default:
        return 0.0;
    }
  }

  /// Stranka ustvari nov ticket za rezervacijo.
  /// Ta ticket je takoj viden vsem zaposlenim (Employee) in Adminom.
  BorrowRequest createBorrowRequest({
    required String itemId,
    required int quantity,
    required DateTime startDate,
    required DateTime endDate,
    String? customNote,
    String? promoCode,
  }) {
    final user = _currentUser;
    if (user == null) {
      throw Exception('You must be signed in to create a reservation ticket.');
    }

    final itemIdx = _items.indexWhere((i) => i.id == itemId);
    if (itemIdx == -1) {
      throw Exception('Selected item no longer exists.');
    }

    final item = _items[itemIdx];
    if (!item.isAvailable || quantity <= 0 || quantity > item.availableStock) {
      throw Exception(
        'Requested quantity ($quantity) exceeds available stock (${item.availableStock}).',
      );
    }

    final discount = evaluatePromoCode(promoCode);
    final ticketId = 'TCK-${1000 + _borrowRequests.length + 1}';

    final request = BorrowRequest(
      id: ticketId,
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      itemId: item.id,
      itemName: item.name,
      quantity: quantity,
      startDate: startDate,
      endDate: endDate,
      dailyRate: item.dailyRate,
      discountPercent: discount,
      status: BorrowStatus.pending,
      createdAt: DateTime.now(),
      staffNote: customNote,
    );

    _borrowRequests.insert(0, request);

    _recordAudit(
      actorName: user.name,
      actorRole: user.role,
      action: 'New Ticket Created (#$ticketId)',
      details:
          'Requested ${quantity}x ${item.name} for ${request.durationDays} days (€${request.totalCost.toStringAsFixed(2)}).',
    );

    _addNotification(
      userId: 'STAFF',
      title: 'New Reservation Ticket #$ticketId',
      message:
          '${user.name} requested ${quantity}x ${item.name} (${request.durationDays}d). Waiting for staff approval.',
    );

    _addNotification(
      userId: user.id,
      title: 'Ticket #$ticketId Submitted',
      message:
          'Your reservation for ${item.name} was sent to an Employee for approval.',
    );

    notifyListeners();
    return request;
  }

  /// Employee ali Admin odobri ticket -> zmanjša zalogo in izda račun (Bill)
  void approveBorrowRequest(String requestId, {String? staffNote}) {
    final reqIdx = _borrowRequests.indexWhere((r) => r.id == requestId);
    if (reqIdx == -1) return;

    final req = _borrowRequests[reqIdx];
    if (req.status != BorrowStatus.pending) return;

    final itemIdx = _items.indexWhere((i) => i.id == req.itemId);
    if (itemIdx == -1) {
      throw Exception('Item not found in inventory.');
    }

    final item = _items[itemIdx];
    if (item.availableStock < req.quantity) {
      throw Exception(
        'Insufficient stock to approve ticket (Available: ${item.availableStock}, Needed: ${req.quantity}).',
      );
    }

    // 1. Zmanjšaj razpoložljivo zalogo in povečaj števec izposoj
    _items[itemIdx] = item.copyWith(
      availableStock: item.availableStock - req.quantity,
      totalRentalsCount: item.totalRentalsCount + req.quantity,
    );

    // 2. Posodobi status ticketa
    final staffName = _currentUser?.name ?? 'Staff Member';
    final updatedReq = req.copyWith(
      status: BorrowStatus.approved,
      handledByStaffName: staffName,
      staffNote: (staffNote != null && staffNote.trim().isNotEmpty)
          ? staffNote.trim()
          : req.staffNote,
    );
    _borrowRequests[reqIdx] = updatedReq;

    // 3. Samodejno ustvari račun (Invoice)
    final billId = 'INV-${2000 + _bills.length + 1}';
    final newBill = Bill(
      id: billId,
      borrowRequestId: updatedReq.id,
      userId: updatedReq.userId,
      userName: updatedReq.userName,
      itemName:
          '${updatedReq.quantity}x ${updatedReq.itemName} (${updatedReq.durationDays}d)',
      amount: updatedReq.totalCost,
      issuedDate: DateTime.now(),
      dueDate: updatedReq.endDate.add(const Duration(days: 5)),
      status: BillStatus.unpaid,
    );
    _bills.insert(0, newBill);

    _recordAudit(
      action: 'Ticket Approved (#${updatedReq.id})',
      details:
          'Approved by $staffName. Issued invoice #$billId (€${newBill.totalAmount.toStringAsFixed(2)}).',
    );

    _addNotification(
      userId: updatedReq.userId,
      title: 'Ticket #${updatedReq.id} Approved!',
      message:
          '$staffName approved your reservation for ${updatedReq.itemName}. Invoice #$billId generated.',
    );

    notifyListeners();
  }

  /// Employee ali Admin zavrne ticket
  void rejectBorrowRequest(String requestId, {String? staffNote}) {
    final reqIdx = _borrowRequests.indexWhere((r) => r.id == requestId);
    if (reqIdx == -1) return;

    final req = _borrowRequests[reqIdx];
    if (req.status != BorrowStatus.pending) return;

    final staffName = _currentUser?.name ?? 'Staff Member';
    _borrowRequests[reqIdx] = req.copyWith(
      status: BorrowStatus.rejected,
      handledByStaffName: staffName,
      staffNote: staffNote?.trim(),
    );

    _recordAudit(
      action: 'Ticket Rejected (#${req.id})',
      details: 'Declined reservation for ${req.userName} (${req.itemName}).',
    );

    _addNotification(
      userId: req.userId,
      title: 'Ticket #${req.id} Rejected',
      message:
          'Your reservation for ${req.itemName} was declined by $staffName.',
    );

    notifyListeners();
  }

  /// Vračilo opreme s pregledom stanja (Condition Check).
  /// Če je oprema vrnjena poškodovana ali prepozno, se računu prišteje penaltyFee.
  void markItemReturned(
    String requestId, {
    double damageOrLateFee = 0.0,
    String conditionNote = 'Returned in good condition',
  }) {
    final reqIdx = _borrowRequests.indexWhere((r) => r.id == requestId);
    if (reqIdx == -1) return;

    final req = _borrowRequests[reqIdx];
    if (req.status != BorrowStatus.approved) return;

    // 1. Vrni količino v razpoložljivo zalogo
    final itemIdx = _items.indexWhere((i) => i.id == req.itemId);
    if (itemIdx != -1) {
      final item = _items[itemIdx];
      final restoredStock =
          (item.availableStock + req.quantity).clamp(0, item.totalStock);
      _items[itemIdx] = item.copyWith(availableStock: restoredStock);
    }

    // 2. Posodobi ticket
    _borrowRequests[reqIdx] = req.copyWith(
      status: BorrowStatus.returned,
      returnConditionNote: conditionNote,
    );

    // 3. Če je bil zaračunan dodatek za poškodbo/zamudo, posodobi povezani račun
    if (damageOrLateFee > 0) {
      final billIdx =
          _bills.indexWhere((b) => b.borrowRequestId == requestId);
      if (billIdx != -1) {
        final bill = _bills[billIdx];
        _bills[billIdx] = bill.copyWith(
          penaltyFee: bill.penaltyFee + damageOrLateFee,
        );
      }
    }

    _recordAudit(
      action: 'Equipment Returned (#${req.id})',
      details:
          '${req.itemName} returned by ${req.userName}. Note: $conditionNote${damageOrLateFee > 0 ? " (+€${damageOrLateFee.toStringAsFixed(0)} fee)" : ""}.',
    );

    _addNotification(
      userId: req.userId,
      title: 'Equipment Return Logged (#${req.id})',
      message:
          '${req.itemName} marked as returned ($conditionNote).',
    );

    notifyListeners();
  }

  /// Stranka lahko podaljša aktivno izposojo za +2 dni (posodobi tudi račun)
  void extendActiveRental(String requestId, {int extraDays = 2}) {
    final reqIdx = _borrowRequests.indexWhere((r) => r.id == requestId);
    if (reqIdx == -1) return;

    final req = _borrowRequests[reqIdx];
    if (req.status != BorrowStatus.approved) return;

    final updatedReq = req.copyWith(
      endDate: req.endDate.add(Duration(days: extraDays)),
    );
    _borrowRequests[reqIdx] = updatedReq;

    // Posodobi znesek na pripadajočem računu, če še ni plačan
    final billIdx = _bills.indexWhere((b) => b.borrowRequestId == requestId);
    if (billIdx != -1 && _bills[billIdx].status != BillStatus.paid) {
      _bills[billIdx] = _bills[billIdx].copyWith(
        amount: updatedReq.totalCost,
        itemName:
            '${updatedReq.quantity}x ${updatedReq.itemName} (${updatedReq.durationDays}d)',
      );
    }

    _recordAudit(
      action: 'Rental Extended (#${req.id})',
      details:
          '${req.userName} extended ${req.itemName} by +$extraDays days.',
    );
    notifyListeners();
  }

  /// Stranka prekliče svoj čakajoči ticket
  void cancelBorrowRequest(String requestId) {
    final reqIdx = _borrowRequests.indexWhere((r) => r.id == requestId);
    if (reqIdx == -1) return;
    final req = _borrowRequests[reqIdx];
    if (req.status != BorrowStatus.pending) return;

    _borrowRequests[reqIdx] = req.copyWith(status: BorrowStatus.cancelled);
    notifyListeners();
  }

  // ===========================================================================
  // RAČUNI, PLAČILA IN POSODOBITEV ROI GRAFA
  // ===========================================================================

  List<Bill> getBillsForUser(String userId) {
    return _bills.where((b) => b.userId == userId).toList();
  }

  /// Stranka označi račun kot plačan -> čaka na verifikacijo osebja
  void requestBillPaymentApproval(String billId) {
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx == -1) return;
    final bill = _bills[idx];
    if (bill.status == BillStatus.paid || bill.status == BillStatus.waived) {
      return;
    }

    _bills[idx] = bill.copyWith(status: BillStatus.pendingApproval);

    _addNotification(
      userId: 'STAFF',
      title: 'Payment Verification Needed (#${bill.id})',
      message:
          '${bill.userName} paid invoice #${bill.id} (€${bill.totalAmount.toStringAsFixed(2)}).',
    );

    notifyListeners();
  }

  /// Employee ali Admin potrdi plačilo -> znesek se prišteje v ustvarjene prihodke (ROI graf)
  void approveBillPayment(String billId) {
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx == -1) return;

    final bill = _bills[idx];
    if (bill.status == BillStatus.paid) return;

    final staffName = _currentUser?.name ?? 'Staff Member';
    _bills[idx] = bill.copyWith(
      status: BillStatus.paid,
      paidDate: DateTime.now(),
      approvedByStaffName: staffName,
    );

    // Poveži plačilo z artiklom za takojšnjo osvežitev ROI grafa
    final reqIdx =
        _borrowRequests.indexWhere((r) => r.id == bill.borrowRequestId);
    if (reqIdx != -1) {
      final req = _borrowRequests[reqIdx];
      final itemIdx = _items.indexWhere((i) => i.id == req.itemId);
      if (itemIdx != -1) {
        final item = _items[itemIdx];
        _items[itemIdx] = item.copyWith(
          totalRevenueGenerated: item.totalRevenueGenerated + bill.totalAmount,
        );
      }
    }

    _recordAudit(
      action: 'Invoice Payment Verified (#${bill.id})',
      details:
          'Verified €${bill.totalAmount.toStringAsFixed(2)} from ${bill.userName}. ROI metrics updated.',
    );

    _addNotification(
      userId: bill.userId,
      title: 'Payment Confirmed (#${bill.id})',
      message:
          'Your payment of €${bill.totalAmount.toStringAsFixed(2)} was verified by $staffName.',
    );

    notifyListeners();
  }

  /// Ekskluzivna pravica Administratorja: odobritev 20% popusta ali odpis računa
  void applyAdminDiscountOrWaive(String billId, {required bool waiveCompletely}) {
    if (_currentUser?.isAdmin != true) {
      throw Exception('Only Administrators can waive or discount invoices.');
    }
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx == -1) return;

    final bill = _bills[idx];
    if (waiveCompletely) {
      _bills[idx] = bill.copyWith(
        status: BillStatus.waived,
        approvedByStaffName: _currentUser?.name,
      );
      _recordAudit(
        action: 'Invoice Waived (#${bill.id})',
        details: 'Admin waived invoice for ${bill.userName}.',
      );
    } else {
      _bills[idx] = bill.copyWith(
        amount: bill.amount * 0.8,
        penaltyFee: 0.0,
      );
      _recordAudit(
        action: 'Admin Discount Applied (#${bill.id})',
        details: 'Applied 20% discount & cleared fees for ${bill.userName}.',
      );
    }
    notifyListeners();
  }

  // ===========================================================================
  // OBVESTILA (NOTIFICATIONS)
  // ===========================================================================

  void _addNotification({
    required String userId,
    required String title,
    required String message,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'ntf-${DateTime.now().microsecondsSinceEpoch}',
        userId: userId,
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<AppNotification> get notificationsForCurrentUser {
    final user = _currentUser;
    if (user == null) return [];
    return _notifications.where((n) {
      if (user.isStaff && n.userId == 'STAFF') return true;
      if (user.isAdmin && n.userId == 'ADMIN') return true;
      return n.userId == user.id;
    }).toList();
  }

  int get unreadNotificationCount {
    return notificationsForCurrentUser.where((n) => !n.isRead).length;
  }

  void markAllNotificationsRead() {
    for (final n in notificationsForCurrentUser) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // ===========================================================================
  // ANALITIKA IN ROI METRIKE (ADMIN DASHBOARD)
  // ===========================================================================

  double get totalUnitCostBasis => _items.fold(
        0.0,
        (sum, item) => sum + item.purchaseCost,
      );

  double get totalRealizedRevenue => _items.fold(
        0.0,
        (sum, item) => sum + item.totalRevenueGenerated,
      );

  double get pendingReceivables => _bills
      .where((b) =>
          b.status == BillStatus.unpaid ||
          b.status == BillStatus.pendingApproval ||
          b.status == BillStatus.overdue)
      .fold(0.0, (sum, b) => sum + b.totalAmount);

  double get overallRoiPercentage {
    if (totalUnitCostBasis <= 0) return 0.0;
    return ((totalRealizedRevenue - totalUnitCostBasis) / totalUnitCostBasis) *
        100;
  }

  double get overallCostRecoveryPercentage {
    if (totalUnitCostBasis <= 0) return 100.0;
    return (totalRealizedRevenue / totalUnitCostBasis) * 100;
  }
}