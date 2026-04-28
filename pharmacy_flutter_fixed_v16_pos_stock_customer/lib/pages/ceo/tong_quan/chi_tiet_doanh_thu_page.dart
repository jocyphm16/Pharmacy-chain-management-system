import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChiTietDoanhThuPage extends StatelessWidget {
  final Map<String, dynamic> branch;
  final List<Map<String, dynamic>> invoices;
  final List<Map<String, dynamic>> medicines;
  final List<Map<String, dynamic>> staffs;

  const ChiTietDoanhThuPage({
    Key? key,
    required this.branch,
    required this.invoices,
    required this.medicines,
    required this.staffs,
  }) : super(key: key);

  String money(num value) => NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);

  double _importPriceOf(String medicineName) {
    final lower = medicineName.trim().toLowerCase();
    for (final medicine in medicines) {
      final name = (medicine['name'] ?? '').toString().trim().toLowerCase();
      if (name == lower) {
        final raw = medicine['importPrice'] ?? medicine['price'] ?? 0;
        return raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final branchId = branch['id'];
    final branchName = (branch['name'] ?? 'Chi nhánh').toString();
    final branchMedicines = medicines.where((m) => m['branchId'] == branchId).toList();
    final branchStaffs = staffs.where((s) => s['branchId'] == branchId).toList();

    int invoiceCount = invoices.length;
    int totalQuantity = 0;
    double revenue = 0;
    double profit = 0;
    final Map<String, int> soldByProduct = {};
    final List<Map<String, dynamic>> recentTransactions = [...invoices]
      ..sort((a, b) => '${b['date']} ${b['time']}'.compareTo('${a['date']} ${a['time']}'));

    for (final invoice in invoices) {
      final total = invoice['total'] is num ? (invoice['total'] as num).toDouble() : double.tryParse('${invoice['total']}') ?? 0;
      revenue += total;
      final items = List<Map<String, dynamic>>.from(invoice['items'] ?? const []);
      for (final item in items) {
        final qty = item['qty'] is num ? (item['qty'] as num).toInt() : int.tryParse('${item['qty']}') ?? 0;
        final price = item['price'] is num ? (item['price'] as num).toDouble() : double.tryParse('${item['price']}') ?? 0;
        final name = (item['name'] ?? 'Không rõ').toString();
        totalQuantity += qty;
        soldByProduct[name] = (soldByProduct[name] ?? 0) + qty;
        profit += (price - _importPriceOf(name)) * qty;
      }
    }

    final aov = invoiceCount == 0 ? 0 : revenue / invoiceCount;
    final lowStockCount = branchMedicines.where((m) {
      final stock = m['stock'] is num ? (m['stock'] as num).toInt() : int.tryParse('${m['stock']}') ?? 0;
      return stock <= 10;
    }).length;
    final topProducts = soldByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(branchName),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TỔNG QUAN CHI NHÁNH', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(money(revenue), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Địa chỉ: ${branch['address'] ?? 'Chưa cập nhật'}', style: const TextStyle(color: Colors.white)),
                Text('SĐT: ${branch['phone'] ?? 'Chưa cập nhật'}', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _kpi('Doanh thu', money(revenue), Icons.payments, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _kpi('Lãi tạm tính', money(profit), Icons.trending_up, profit >= 0 ? Colors.orange : Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _kpi('Hóa đơn', '$invoiceCount', Icons.receipt_long, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _kpi('SL đã bán', '$totalQuantity', Icons.shopping_bag, Colors.purple)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _kpi('Giá trị/đơn', money(aov), Icons.bar_chart, Colors.teal)),
              const SizedBox(width: 10),
              Expanded(child: _kpi('Thuốc sắp hết', '$lowStockCount', Icons.warning_amber, Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 18),
          _sectionTitle('Nhân sự chi nhánh'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _simpleRow('Quản lý + nhân viên', '${branchStaffs.length} người'),
                  const Divider(),
                  ...branchStaffs.take(5).map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _simpleRow(
                      s['name']?.toString() ?? '',
                      s['role']?.toString() ?? '',
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('Sản phẩm bán nhiều'),
          if (topProducts.isEmpty)
            _emptyCard('Chưa có dữ liệu bán hàng cho chi nhánh này')
          else
            ...topProducts.take(5).toList().asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final item = entry.value;
              final importPrice = _importPriceOf(item.key);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Text('$rank')),
                  title: Text(item.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Đã bán: ${item.value} | Giá vốn: ${money(importPrice)}'),
                  trailing: Text('${item.value} sp', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ),
              );
            }),
          const SizedBox(height: 18),
          _sectionTitle('Hóa đơn gần đây'),
          if (recentTransactions.isEmpty)
            _emptyCard('Chưa có hóa đơn')
          else
            ...recentTransactions.take(8).map((inv) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text(inv['id']?.toString() ?? 'Hóa đơn', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${inv['customerName'] ?? 'Khách lẻ'} • ${inv['time'] ?? ''} ${inv['date'] ?? ''}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(money((inv['total'] ?? 0) as num), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    Text((inv['staffName'] ?? '').toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            )),
          const SizedBox(height: 18),
          _sectionTitle('Cảnh báo tồn kho'),
          if (branchMedicines.isEmpty)
            _emptyCard('Không có dữ liệu kho')
          else
            ...branchMedicines.where((m) {
              final stock = m['stock'] is num ? (m['stock'] as num).toInt() : int.tryParse('${m['stock']}') ?? 0;
              return stock <= 10;
            }).take(8).map((m) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.orange[50], child: const Icon(Icons.medication, color: Colors.orange)),
                title: Text(m['name']?.toString() ?? ''),
                subtitle: Text('Nhà SX: ${m['manufacturer'] ?? 'Chưa có'}'),
                trailing: Text('Còn ${m['stock']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _kpi(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _simpleRow(String left, String right) => Row(
        children: [
          Expanded(child: Text(left, style: const TextStyle(fontWeight: FontWeight.w500))),
          const SizedBox(width: 12),
          Text(right, style: const TextStyle(color: Colors.black54)),
        ],
      );

  Widget _emptyCard(String text) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(text, style: const TextStyle(color: Colors.grey)),
        ),
      );
}
