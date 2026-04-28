import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'import_history_page.dart';
import '../../../data/supplier_data.dart'; // IMPORT DATA

class SupplierTab extends StatefulWidget {
  const SupplierTab({Key? key}) : super(key: key);
  @override
  State<SupplierTab> createState() => _SupplierTabState();
}

class _SupplierTabState extends State<SupplierTab> {
  void _showAddSupplierDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Đối Tác Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên Công ty')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại'), keyboardType: TextInputType.phone),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Địa chỉ')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  globalSuppliers.add({
                    'id': 'SUP${DateTime.now().millisecondsSinceEpoch}',
                    'name': nameCtrl.text, 'contact': phoneCtrl.text, 'email': emailCtrl.text, 'address': addressCtrl.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('LƯU'),
          ),
        ],
      ),
    );
  }

  // .... Các hàm _makeContact giữ nguyên như file cũ của bạn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đối tác cung ứng', style: TextStyle(fontWeight: FontWeight.bold)), elevation: 0.5),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: globalSuppliers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sup = globalSuppliers[index];
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
            child: ExpansionTile(
              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.business, color: Colors.white)),
              title: Text(sup['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('SĐT: ${sup['contact']}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(children: [Icon(Icons.location_on, size: 18, color: Colors.grey), const SizedBox(width: 10), Expanded(child: Text('Địa chỉ: ${sup['address']}', style: const TextStyle(color: Colors.black87)))]),
                      const SizedBox(height: 8),
                      Row(children: [Icon(Icons.email, size: 18, color: Colors.grey), const SizedBox(width: 10), Expanded(child: Text('Email: ${sup['email']}', style: const TextStyle(color: Colors.black87)))]),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ImportHistoryPage(supplierId: sup['id']!, supplierName: sup['name']!))),
                              icon: const Icon(Icons.history), label: const Text('Lịch sử nhập')
                          ),
                          // Nút liên hệ
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
      floatingActionButton: FloatingActionButton(onPressed: _showAddSupplierDialog, backgroundColor: Colors.blueAccent, child: const Icon(Icons.person_add_alt_1, color: Colors.white)),
    );
  }
}