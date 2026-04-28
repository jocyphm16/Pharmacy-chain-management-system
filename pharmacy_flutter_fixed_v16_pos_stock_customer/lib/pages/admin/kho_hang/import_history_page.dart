import 'package:flutter/material.dart';

class ImportHistoryPage extends StatefulWidget {
  final String supplierName;
  final String supplierId; // Dùng ID này để query Database

  const ImportHistoryPage({
    Key? key,
    required this.supplierName,
    required this.supplierId
  }) : super(key: key);

  @override
  State<ImportHistoryPage> createState() => _ImportHistoryPageState();
}

class _ImportHistoryPageState extends State<ImportHistoryPage> {
  // Sau này danh sách này sẽ lấy từ Database bằng supplierId
  final List<Map<String, dynamic>> _historyData = [
    {
      'invoice_id': 'HDN001',
      'date': '20/03/2026',
      'total_amount': '15.000.000đ',
      'status': 'Đã thanh toán',
      'items': 'Paracetamol (500), Amoxicillin (200)'
    },
    {
      'invoice_id': 'HDN042',
      'date': '15/02/2026',
      'total_amount': '8.500.000đ',
      'status': 'Còn nợ',
      'items': 'Vitamin C (1000), Panadol (100)'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lịch sử nhập hàng', style: TextStyle(fontSize: 18)),
            Text(widget.supplierName, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _historyData.isEmpty
          ? const Center(child: Text('Chưa có lịch sử nhập hàng.'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _historyData.length,
        itemBuilder: (context, index) {
          final item = _historyData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ExpansionTile(
              title: Text('Mã đơn: ${item['invoice_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Ngày nhập: ${item['date']}'),
              trailing: Text(item['total_amount'],
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chi tiết lô hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item['items']),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trạng thái:'),
                          Chip(
                            label: Text(item['status'], style: const TextStyle(fontSize: 12)),
                            backgroundColor: item['status'] == 'Đã thanh toán'
                                ? Colors.green.shade50 : Colors.red.shade50,
                            labelStyle: TextStyle(color: item['status'] == 'Đã thanh toán'
                                ? Colors.green : Colors.red),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}