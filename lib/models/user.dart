enum UserRole { admin, employee, customer }

class User {
  final String id;
  final String name;
  final UserRole role;
  final List<String> borrowedItemIds; // History of borrowed items (IDs)

  User({
    required this.id,
    required this.name,
    required this.role,
    this.borrowedItemIds = const [],
  });
}
