class User {
  final String id;
  final String fullName;
  final String? avatar;
  final bool isOnline;
  final UserRole role;

  User({
    required this.id,
    required this.fullName,
    this.avatar,
    this.isOnline = false,
    this.role = UserRole.user,
  });
}

enum UserRole { user, staff, support, admin }
