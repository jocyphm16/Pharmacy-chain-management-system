import 'package:flutter/material.dart';

class TroGiupHoTroPage extends StatelessWidget {
  const TroGiupHoTroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                Icon(Icons.headset_mic, size: 60, color: Colors.blue),
                SizedBox(height: 16),
                Text('Trung tâm hỗ trợ Dược sĩ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Hotline Admin: 0988.123.456', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Email: support@nhathuoc.com', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Câu hỏi thường gặp (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          _buildFAQItem('Làm sao để tạo yêu cầu nhập thuốc?', 'Bạn vào mục Trang chủ -> Chọn Kiểm kho -> Nhấn vào thuốc sắp hết và nhập số lượng cần gửi lên Admin.'),
          _buildFAQItem('Nếu chốt ca bị lệch tiền thì sao?', 'Phần mềm sẽ tự động báo cáo lên Admin khoản tiền lệch (Thừa/Thiếu). Admin sẽ kiểm tra và đối soát lại cùng bạn.'),
          _buildFAQItem('Cách bán hàng bằng đơn thuốc điện tử?', 'Tại Trang chủ, nhấn "Quét đơn thuốc", đưa mã QR của khách vào khung camera. Hệ thống sẽ tự đưa dữ liệu sang máy POS.'),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: Colors.black87, height: 1.5)),
          )
        ],
      ),
    );
  }
}