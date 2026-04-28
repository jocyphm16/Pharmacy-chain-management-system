// lib/pages/admin/nhan_vien/chi_tiet_nhan_vien_page.dart

import 'package:flutter/material.dart';

class ChiTietNhanVienPage extends StatelessWidget {
  final Map<String, String> staff;

  const ChiTietNhanVienPage({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isActive = staff['status'] == 'Hoạt động';

    // GIẢ LẬP DỮ LIỆU TỪ API
    final String mockAddress = '123 Đường Láng, Đống Đa, Hà Nội';
    final String mockEmail = '${staff['id']?.toLowerCase()}@nhathuoc.com';
    final String mockJoinDate = '15/01/2023';

    // Đã đổi Doanh thu thành Điểm tích lũy theo yêu cầu của bạn
    final String mockTotalOrders = '1,245';
    final String mockPoints = '4,520';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hồ sơ nhân sự', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_document),
            tooltip: 'Sửa thông tin',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng chỉnh sửa đang phát triển')),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER (Phần thông tin tóm tắt trên cùng)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Colors.blue[300]),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: isActive ? Colors.green : Colors.orange,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    staff['name'] ?? 'Chưa cập nhật',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${staff['role']} • ${staff['id']}',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. THỐNG KÊ HIỆU SUẤT LÀM VIỆC (KPI)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildKpiCard('Đơn đã bán', mockTotalOrders, Icons.receipt_long, Colors.orange)),
                  const SizedBox(width: 12),
                  // ĐÃ SỬA: Thay Doanh số thành Điểm tích lũy, đổi Icon thành ngôi sao, đổi màu tím cho đẹp
                  Expanded(child: _buildKpiCard('Điểm tích lũy', mockPoints, Icons.stars, Colors.purple)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. THÔNG TIN CÁ NHÂN CHI TIẾT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Thông tin liên hệ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(height: 1),
                    _buildInfoTile(Icons.phone_android, 'Số điện thoại', staff['phone'] ?? 'Chưa cập nhật'),
                    const Divider(height: 1, indent: 50),
                    _buildInfoTile(Icons.email_outlined, 'Email', mockEmail),
                    const Divider(height: 1, indent: 50),
                    _buildInfoTile(Icons.location_on_outlined, 'Địa chỉ', mockAddress),
                    const Divider(height: 1, indent: 50),
                    _buildInfoTile(Icons.calendar_month_outlined, 'Ngày gia nhập', mockJoinDate),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4. NÚT HÀNH ĐỘNG KHẨN CẤP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_reset, color: Colors.redAccent),
                  label: const Text('Reset mật khẩu nhân viên', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.redAccent.shade100, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget vẽ thẻ thống kê KPI
  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // Widget vẽ từng dòng thông tin
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}