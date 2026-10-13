enum UserRole { admin, employee, customer }

class User {
  final String id;
  final String name;
  final UserRole role;
  final List<String> borrowedItemIds; // History of borrowed items (IDs)
  final String contactInfo;
  final int strikes;
  final bool isSuspended;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.borrowedItemIds = const [],
    this.contactInfo = '',
    this.strikes = 0,
    this.isSuspended = false,
  });

  User copyWith({
    String? name,
    UserRole? role,
    List<String>? borrowedItemIds,
    String? contactInfo,
    int? strikes,
    bool? isSuspended,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      borrowedItemIds: borrowedItemIds ?? this.borrowedItemIds,
      contactInfo: contactInfo ?? this.contactInfo,
      strikes: strikes ?? this.strikes,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }
}
