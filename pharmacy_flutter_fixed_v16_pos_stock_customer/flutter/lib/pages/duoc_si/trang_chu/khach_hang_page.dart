import 'package:flutter/material.dart';
import '../../../data/customer_data.dart'; // IMPORT DATA

class KhachHangPage extends StatefulWidget {
  const KhachHangPage({Key? key}) : super(key: key);

  @override
  State<KhachHangPage> createState() => _KhachHangPageState();
}

class _KhachHangPageState extends State<KhachHangPage> {
  String _searchQuery = '';

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Kim cương': return Colors.purple;
      case 'Vàng': return Colors.orange.shade700;
      case 'Bạc': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // SỬ DỤNG globalCustomers THAY VÌ _customers
    List<Map<String, dynamic>> filteredCustomers = globalCustomers.where((c) {
      final query = _searchQuery.toLowerCase();
      return c['phone'].contains(query) || c['name'].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('KHÁCH HÀNG THÂN THIẾT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showAddCustomerDialog(context),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Nhập số điện thoại hoặc tên khách...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: filteredCustomers.isEmpty
                ? const Center(child: Text('Không tìm thấy khách hàng', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) => _buildCustomerCard(filteredCustomers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    Color levelColor = _getLevelColor(customer['level']);
    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: levelColor.withOpacity(0.1), child: Icon(Icons.person, color: levelColor)),
        title: Row(
          children: [
            Text(customer['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(20)),
              child: Text(customer['level'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        subtitle: Text(customer['phone'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${customer['points']} điểm', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            const Text('Tích lũy', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ', customer['address']),
                _buildInfoRow(Icons.payments_outlined, 'Tổng chi tiêu', '${customer['totalSpent']}đ'),
                _buildInfoRow(Icons.history, 'Lần cuối mua', customer['lastVisit']),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng ký khách thân thiết'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại *', prefixIcon: Icon(Icons.phone))),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên *', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng', prefixIcon: Icon(Icons.location_on))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
          ElevatedButton(
              onPressed: () {
                if (phoneCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                  setState(() {
                    globalCustomers.add({
                      'name': nameCtrl.text, 'phone': phoneCtrl.text, 'address': addressCtrl.text.isEmpty ? 'Chưa cập nhật' : addressCtrl.text,
                      'points': 0, 'level': 'Bạc', 'totalSpent': '0', 'lastVisit': 'Chưa mua'
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm khách hàng mới!')));
                }
              },
              child: const Text('LƯU KHÁCH HÀNG')
          ),
        ],
      ),
    );
  }
}