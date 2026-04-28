import 'package:flutter/material.dart';

class ChiTietDoanhThuPage extends StatelessWidget {
  final String tenChiNhanh;

  const ChiTietDoanhThuPage({Key? key, required this.tenChiNhanh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tenChiNhanh),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Thẻ KPI tổng
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
            ),
            // Đã dọn sạch các từ khóa const gây lỗi ở các cột Column bên dưới
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Doanh Thu', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('500M', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Container(height: 50, width: 1, color: Colors.grey), // Đường kẻ phân cách
                Column(
                  children: [
                    const Text('Đơn Hàng', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('1,250', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ],
                ),
                Container(height: 50, width: 1, color: Colors.grey), // Đường kẻ phân cách
                Column(
                  children: [
                    const Text('AOV', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('400k', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Danh mục bán chạy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTopProductItem('1', 'Panadol Extra', '1,200 hộp', '18,000,000 đ'),
          _buildTopProductItem('2', 'Amoxicillin 500mg', '950 vỉ', '14,250,000 đ'),
          _buildTopProductItem('3', 'Vitamin C', '800 lọ', '40,000,000 đ'),

          const SizedBox(height: 24),
          const Text('Lịch sử giao dịch (Real-time)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTransactionItem('Mã đơn: #DH-10045', '14:30 - Hôm nay', '+ 250,000 đ'),
          _buildTransactionItem('Mã đơn: #DH-10044', '14:15 - Hôm nay', '+ 1,500,000 đ'),
          _buildTransactionItem('Mã đơn: #DH-10043', '13:40 - Hôm nay', '+ 85,000 đ'),
        ],
      ),
    );
  }

  Widget _buildTopProductItem(String rank, String name, String qty, String revenue) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Text(rank, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Đã bán: $qty'),
        trailing: Text(revenue, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String time, String amount) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: Text(amount, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}