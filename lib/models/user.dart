/// Vloge uporabnikov v sistemu z jasno hierarhijo pravic:
/// customer < employee < admin
enum UserRole { customer, employee, admin }

/// Model za obvestila v aplikaciji (prikazana v NotificationBell)
class AppNotification {
  final String id;
  final String userId; // ID uporabnika, 'STAFF' za osebje ali 'ADMIN' samo za admine
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}

/// Model za dnevnik sistemskih dogodkov (viden izključno Administratorju)
class AuditLogEntry {
  final String id;
  final String actorName;
  final UserRole actorRole;
  final String action;
  final String details;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.id,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.details,
    required this.timestamp,
  });
}

/// Model uporabnika aplikacije
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  /// Ali ima uporabnik polne administratorske pravice
  bool get isAdmin => role == UserRole.admin;

  /// Ali je uporabnik zaposleni (operativno osebje)
  bool get isEmployee => role == UserRole.employee;

  /// Ali spada uporabnik med osebje (Employee ali Admin)
  bool get isStaff => role == UserRole.admin || role == UserRole.employee;

  /// Čitljiv naziv vloge
  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.employee:
        return 'Employee';
      case UserRole.customer:
        return 'Customer';
    }
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}