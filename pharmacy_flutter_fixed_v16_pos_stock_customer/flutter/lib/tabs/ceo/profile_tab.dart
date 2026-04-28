import 'package:flutter/material.dart';

import '../../models/app_session.dart';
import '../../services/auth_service.dart';

class CeoProfileTab extends StatelessWidget {
  const CeoProfileTab({Key? key}) : super(key: key);

  String _roleLabel(String role) {
    switch (role) {
      case 'CEO':
        return 'CEO tổng';
      case 'MANAGER':
        return 'Quản lý cửa hàng';
      default:
        return 'Dược sĩ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return FutureBuilder<AppSession?>(
      future: auth.currentSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final session = snapshot.data;
        if (session == null) {
          return const Center(child: Text('Không có thông tin tài khoản'));
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 3)),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    session.fullName.isNotEmpty ? session.fullName[0].toUpperCase() : 'Q',
                    style: const TextStyle(fontSize: 44, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(session.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            const SizedBox(height: 6),
            Center(child: Text(_roleLabel(session.role), style: const TextStyle(color: Colors.grey, fontSize: 16))),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.person_outline), title: const Text('Tên đăng nhập'), subtitle: Text(session.username)),
                  const Divider(height: 0),
                  ListTile(leading: const Icon(Icons.storefront_outlined), title: const Text('Cửa hàng phụ trách'), subtitle: Text(session.branchName ?? 'Toàn hệ thống')),
                  const Divider(height: 0),
                  ListTile(leading: const Icon(Icons.badge_outlined), title: const Text('Mã người dùng'), subtitle: Text('${session.userId}')),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu sẽ được mở rộng thêm trong bước sau')));
                },
                icon: const Icon(Icons.lock_outline),
                label: const Text('Đổi mật khẩu'),
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ],
        );
      },
    );
  }
}
