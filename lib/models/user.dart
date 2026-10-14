enum UserRole { admin, employee, customer }

/// Represents a system user, carrying their role-based access information,
/// profile details, and history of actions.
class User {
  final String id;
  final String firstName;
  final String lastName;
  final UserRole role;
  final List<String> borrowedItemIds; // History of borrowed items (IDs)
  final String phoneNumber;
  final String address;
  final int strikes;
  final bool isSuspended;

  String get name => '$firstName $lastName'.trim();

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.borrowedItemIds = const [],
    this.phoneNumber = '',
    this.address = '',
    this.strikes = 0,
    this.isSuspended = false,
  });

  User copyWith({
    String? firstName,
    String? lastName,
    UserRole? role,
    List<String>? borrowedItemIds,
    String? phoneNumber,
    String? address,
    int? strikes,
    bool? isSuspended,
  }) {
    return User(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      borrowedItemIds: borrowedItemIds ?? this.borrowedItemIds,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      strikes: strikes ?? this.strikes,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }
}
