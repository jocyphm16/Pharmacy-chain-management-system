// lib/tabs/duoc_si/profile_tab.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';

// 1. IMPORT 4 TRANG CHỨC NĂNG MỚI
import '../../pages/duoc_si/tai_khoan/cap_nhat_thong_tin_page.dart';
import '../../pages/duoc_si/tai_khoan/doi_mat_khau_page.dart';
import '../../pages/duoc_si/tai_khoan/lich_su_ca_lam_viec_page.dart';
import '../../pages/duoc_si/tai_khoan/tro_giup_ho_tro_page.dart';
import '../../data/shift_report_data.dart';
class ProfileTab extends StatelessWidget {
  final String fullName;
  final AuthService _authService = AuthService();

  ProfileTab({super.key, required this.fullName});

  // Hàm xử lý đăng xuất
  void _logout(BuildContext context) async {
    // Hiển thị hộp thoại xác nhận trước khi đăng xuất
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng Dialog
                await _authService.logout(); // Xóa dữ liệu đăng nhập
                // Chuyển về màn hình Login
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen())
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          // 1. Tiêu đề Xanh dương
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              'TÀI KHOẢN CÁ NHÂN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 2. Phần Header Profile
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        // Ảnh đại diện
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade200, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tên và chức vụ
                        Text(
                          fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Dược sĩ bán hàng',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Danh sách Menu chức năng (ĐÃ SỬA SỰ KIỆN CHUYỂN TRANG)
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildMenuTile(
                            context,
                            icon: Icons.person_outline,
                            title: 'Cập nhật thông tin',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => CapNhatThongTinPage(fullName: fullName)));
                            }
                        ),
                        const Divider(height: 1, indent: 60),

                        _buildMenuTile(
                            context,
                            icon: Icons.lock_outline,
                            title: 'Đổi mật khẩu',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const DoiMatKhauPage()));
                            }
                        ),
                        const Divider(height: 1, indent: 60),

                        _buildMenuTile(
                            context,
                            icon: Icons.history,
                            title: 'Lịch sử ca làm việc',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => LichSuCaLamViecPage(pharmacistName: fullName)));
                            }
                        ),
                        const Divider(height: 1, indent: 60),

                        _buildMenuTile(
                            context,
                            icon: Icons.help_outline,
                            title: 'Trợ giúp & Hỗ trợ',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const TroGiupHoTroPage()));
                            }
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. Nút Đăng Xuất
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50, // Nền đỏ nhạt
                          foregroundColor: Colors.red,         // Chữ đỏ đậm
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hỗ trợ vẽ các thanh menu (Đã sửa lại để gọi đúng sự kiện onTap)
  Widget _buildMenuTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.blue, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap, // Thay thế dòng báo lỗi cũ bằng lời gọi hàm chuyển trang
    );
  }
}