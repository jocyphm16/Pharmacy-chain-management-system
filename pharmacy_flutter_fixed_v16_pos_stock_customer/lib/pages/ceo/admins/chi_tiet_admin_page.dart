import 'package:flutter/material.dart';

class ChiTietAdminPage extends StatefulWidget {
  final String tenAdmin;
  const ChiTietAdminPage({Key? key, required this.tenAdmin}) : super(key: key);

  @override
  State<ChiTietAdminPage> createState() => _ChiTietAdminPageState();
}

class _ChiTietAdminPageState extends State<ChiTietAdminPage> {
  bool _isActive = true;
  bool _quyenNhapKho = true;
  bool _quyenXoaHoaDon = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Admin'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.blueAccent, child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.white)),
                const SizedBox(height: 16),
                Text(widget.tenAdmin, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Phụ trách: Chi nhánh Quận 1', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Trạng thái & Bảo mật', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Card(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Tài khoản hoạt động', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_isActive ? 'Đang được phép truy cập hệ thống' : 'Đã khóa quyền truy cập'),
                  value: _isActive,
                  activeColor: Colors.blueAccent,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Colors.orange),
                  title: const Text('Reset mật khẩu'),
                  subtitle: const Text('Đưa về mật khẩu mặc định (123456)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu reset mật khẩu!'))),
                ),
              ],
            ),
          ),
          const Text('Phân quyền nâng cao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Card(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text('Cho phép nhập kho tự do'),
                  value: _quyenNhapKho,
                  activeColor: Colors.blueAccent,
                  onChanged: (val) => setState(() => _quyenNhapKho = val!),
                ),
                CheckboxListTile(
                  title: const Text('Cho phép hủy/xóa hóa đơn'),
                  value: _quyenXoaHoaDon,
                  activeColor: Colors.blueAccent,
                  onChanged: (val) => setState(() => _quyenXoaHoaDon = val!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}