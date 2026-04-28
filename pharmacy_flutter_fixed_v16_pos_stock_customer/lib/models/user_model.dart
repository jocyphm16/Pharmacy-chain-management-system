class UserModel {
  final String username;
  final String role;
  final String? fullName;

  UserModel({
    required this.username,
    required this.role,
    this.fullName,
  });
}