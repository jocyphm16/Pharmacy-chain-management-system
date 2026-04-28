// lib/pages/duoc_si/tai_khoan/lich_su_ca_lam_viec_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/shift_report_data.dart'; // Đã chỉnh lại đường dẫn cho đúng cấu trúc thư mục của bạn

class LichSuCaLamViecPage extends StatelessWidget {
  final String pharmacistName;
  LichSuCaLamViecPage({Key? key, required this.pharmacistName}) : super(key: key);

  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    // Lọc ra các ca của Dược sĩ này
    List<Map<String, dynamic>> myShifts = globalShiftReports
        .where((rep) => rep['pharmacist'] == pharmacistName)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Lịch sử ca làm việc', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800], // Đồng bộ màu với hệ thống
        foregroundColor: Colors.white,
      ),
      body: myShifts.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu ca làm việc nào.', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myShifts.length,
        itemBuilder: (context, index) {
          final report = myShifts[index];

          // Xử lý trạng thái và màu sắc
          bool isConfirmed = report['status'] == 'Đã xác nhận';
          Color statusColor = isConfirmed ? Colors.green : Colors.orange;

          // FIX LỖI ĐỎ MÀN HÌNH: Ép kiểu và xử lý null an toàn (?? 0)
          double cashRevenue = (report['cashRevenue'] ?? 0).toDouble();
          double transferRevenue = (report['transferRevenue'] ?? 0).toDouble();
          double totalRevenue = (report['totalRevenue'] ?? 0).toDouble();

          // Nếu bạn chưa cập nhật reportedCash ở trang gửi, code sẽ lấy bằng cashRevenue để không bị Null
          double reportedCash = (report['reportedCash'] ?? cashRevenue).toDouble();
          double difference = (report['difference'] ?? 0).toDouble();

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ngày: ${report['date']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(report['status'] ?? 'Đã nộp', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  _buildRow('Giờ chốt ca:', report['time'] ?? '--:--'),
                  _buildRow('Số đơn bán:', '${report['totalOrders'] ?? 0} đơn'),
                  _buildRow('Doanh thu hệ thống:', formatCurrency.format(totalRevenue)),
                  _buildRow('Tiền mặt (Sổ sách):', formatCurrency.format(cashRevenue)),
                  _buildRow('Tiền chuyển khoản:', formatCurrency.format(transferRevenue)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(thickness: 0.5),
                  ),
                  _buildRow(
                      'Chênh lệch két:',
                      formatCurrency.format(difference),
                      isHighlight: true,
                      diffVal: difference
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false, double? diffVal}) {
    Color valColor = Colors.black87;
    if (isHighlight && diffVal != null) {
      if (diffVal == 0) valColor = Colors.green;
      else if (diffVal < 0) valColor = Colors.red;
      else valColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600, color: valColor, fontSize: 14)),
        ],
      ),
    );
  }
}