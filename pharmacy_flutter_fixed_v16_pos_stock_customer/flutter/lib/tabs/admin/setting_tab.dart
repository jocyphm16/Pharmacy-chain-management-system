import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static final AuthService _authService = AuthService();

  // 1. Dữ liệu giả lập thông tin cửa hàng (Sau này sẽ lấy từ Database/SharedPreferences)
  Map<String, String> _storeInfo = {
    'name': 'Nhà Thuốc Group 4',
    'address': '123 Đường ABC, Hà Nội',
    'hotline': '0123.456.789',
  };

  // 2. Hàm hiển thị Dialog sửa thông tin cửa hàng
  void _showEditStoreDialog() {
    final nameCtrl = TextEditingController(text: _storeInfo['name']);
    final addressCtrl = TextEditingController(text: _storeInfo['address']);
    final phoneCtrl = TextEditingController(text: _storeInfo['hotline']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa thông tin cửa hàng'),
        content: SingleChildScrollView( // Chống tràn màn hình khi hiện bàn phím
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên nhà thuốc', prefixIcon: Icon(Icons.store)),
              ),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Địa chỉ', prefixIcon: Icon(Icons.location_on)),
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Hotline', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _storeInfo = {
                  'name': nameCtrl.text,
                  'address': addressCtrl.text,
                  'hotline': phoneCtrl.text,
                };
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật thông tin cửa hàng'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('CẬP NHẬT'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống quản trị?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _authService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('ĐĂNG XUẤT'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Cấu hình nhà thuốc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),

          // HIỂN THỊ THÔNG TIN CỬA HÀNG THỰC TẾ
          _buildSettingCard(
            title: _storeInfo['name']!,
            subtitle: 'Địa chỉ: ${_storeInfo['address']}\nHotline: ${_storeInfo['hotline']}',
            icon: Icons.storefront,
            onTap: _showEditStoreDialog, // Bấm để sửa
          ),

          _buildSettingCard(
            title: 'Thuế & VAT',
            subtitle: 'Cấu hình mức thuế mặc định (hiện tại 5%)',
            icon: Icons.receipt_long,
            onTap: () {},
          ),

          const SizedBox(height: 24),
          const Text('Bảo mật & Hệ thống',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Thông báo hết hạn'),
              subtitle: const Text('Cảnh báo khi thuốc còn dưới 3 tháng hạn dùng'),
              value: true,
              onChanged: (val) {},
              secondary: const Icon(Icons.notifications_active, color: Colors.orange),
            ),
          ),

          _buildSettingCard(
            title: 'Sao lưu dữ liệu',
            subtitle: 'Lần cuối: 2 giờ trước',
            icon: Icons.backup,
            trailing: const Icon(Icons.cloud_done, color: Colors.green),
            onTap: () {},
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('ĐĂNG XUẤT HỆ THỐNG', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    required VoidCallback onTap
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        isThreeLine: true, // Cho phép hiển thị subtitle nhiều dòng
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4)),
        trailing: trailing ?? const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
        onTap: onTap,
      ),
    );
  }
}