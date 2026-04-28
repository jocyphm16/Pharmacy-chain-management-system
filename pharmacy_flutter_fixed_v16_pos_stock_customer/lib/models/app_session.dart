class AppSession {
  final String token;
  final int userId;
  final String username;
  final String fullName;
  final String role;
  final int? branchId;
  final String? branchName;

  const AppSession({
    required this.token,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    this.branchId,
    this.branchName,
  });

  bool get isCeo => role == 'CEO';
  bool get isAdmin => isCeo;
  bool get isManager => role == 'MANAGER';
  bool get isStaff => role == 'STAFF';

  String get flutterRole {
    switch (role) {
      case 'CEO':
        return 'admin';
      case 'MANAGER':
        return 'manager';
      default:
        return 'duocsi';
    }
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'userId': userId,
    'username': username,
    'fullName': fullName,
    'role': role,
    'branchId': branchId,
    'branchName': branchName,
  };

  factory AppSession.fromJson(Map<String, dynamic> json) => AppSession(
    token: (json['token'] ?? '').toString(),
    userId: (json['userId'] as num).toInt(),
    username: (json['username'] ?? '').toString(),
    fullName: (json['fullName'] ?? '').toString(),
    role: (json['role'] ?? '').toString(),
    branchId: json['branchId'] == null ? null : (json['branchId'] as num).toInt(),
    branchName: json['branchName']?.toString(),
  );
}
