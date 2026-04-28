// lib/pages/duoc_si/trang_chu/ton_kho_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart'; // IMPORT API SERVICE

class TonKhoPage extends StatefulWidget {
  const TonKhoPage({Key? key}) : super(key: key);

  @override
  State<TonKhoPage> createState() => _TonKhoPageState();
}

class _TonKhoPageState extends State<TonKhoPage> {
  final ApiService _apiService = ApiService();
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicines(); // Tải danh sách kho bằng API
  }

  Future<void> _fetchMedicines() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.fetchMedicines();
      if (mounted) {
        setState(() {
          _medicines = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // HÀM HIỂN THỊ DIALOG VÀ GỌI API GỬI YÊU CẦU
  void _sendRestockRequest(String medicineName) {
    TextEditingController qtyController = TextEditingController(text: '50');
    bool isSending = false; // Trạng thái loading riêng của Popup

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Yêu cầu nhập hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bạn muốn gửi thông báo cho Admin nhập thêm thuốc "$medicineName" với số lượng bao nhiêu?'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    enabled: !isSending, // Khóa ô nhập khi đang gửi
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    decoration: InputDecoration(
                      labelText: 'Số lượng cần nhập', prefixIcon: const Icon(Icons.inventory, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: const Text('HỦY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: isSending ? null : () async {
                    // Kích hoạt Loading trong Dialog
                    setDialogState(() => isSending = true);

                    int requestQty = int.tryParse(qtyController.text) ?? 50;
                    final requestData = {
                      'id': 'YC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      'medicineName': medicineName,
                      'pharmacist': 'Dược sĩ trực',
                      'time': 'Vừa xong',
                      'status': 'Chờ duyệt',
                      'quantity': requestQty,
                    };

                    // Gọi API
                    final result = await _apiService.sendRestockRequest(requestData);

                    // Tắt Loading và hiển thị thông báo
                    setDialogState(() => isSending = false);
                    if (context.mounted) {
                      Navigator.pop(context); // Đóng popup
                      if (result['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.green));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  // Nếu đang gửi thì xoay vòng, nếu không thì hiện chữ GỬI YÊU CẦU
                  child: isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('GỬI YÊU CẦU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedMedicines = _medicines.where((m) {
      String name = m['name']?.toString().toLowerCase() ?? '';
      String id = m['id']?.toString().toLowerCase() ?? '';
      String barcode = m['barcode']?.toString() ?? '';
      String query = _searchQuery.toLowerCase();
      return name.contains(query) || id.contains(query) || barcode.contains(query);
    }).toList();

    // Sắp xếp đưa các thuốc sắp hết lên đầu
    displayedMedicines.sort((a, b) {
      int stockA = a['stock'] ?? 0;
      int stockB = b['stock'] ?? 0;
      if (stockA < 20 && stockB >= 20) return -1;
      if (stockA >= 20 && stockB < 20) return 1;
      return 0;
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kiểm Kho & Tra Cứu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800], foregroundColor: Colors.white, elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue[800], padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên thuốc, mã SP, mã vạch...', hintStyle: TextStyle(color: Colors.blue.shade200),
                prefixIcon: const Icon(Icons.search, color: Colors.white), filled: true, fillColor: Colors.blue[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng sản phẩm: ${displayedMedicines.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const Row(
                  children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18), SizedBox(width: 4), Text('Sắp hết (< 20)', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold))],
                )
              ],
            ),
          ),

          // HIỂN THỊ LOADING HOẶC DANH SÁCH
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedMedicines.isEmpty
                ? const Center(child: Text('Không tìm thấy thuốc nào', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: displayedMedicines.length,
              itemBuilder: (context, index) {
                final item = displayedMedicines[index];
                final int stock = item['stock'] ?? 0;
                final bool isLowStock = stock < 20;

                return Card(
                  elevation: 1, margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isLowStock ? Colors.red.shade200 : Colors.transparent, width: 1.5)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _sendRestockRequest(item['name'] ?? 'Thuốc không tên'),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: isLowStock ? Colors.red.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.medication_liquid, color: isLowStock ? Colors.red : Colors.blue[700], size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? 'Chưa cập nhật', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Mã SP: ${item['id']} | Lô: ${item['batch'] ?? 'N/A'}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Vị trí: ${item['location'] ?? 'Chưa xếp kệ'}', style: TextStyle(color: Colors.blue[700], fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formatCurrency.format(item['price'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: isLowStock ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(6)),
                                child: Text('Tồn: $stock ${item['unit'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              if (isLowStock) ...[
                                const SizedBox(height: 4),
                                const Text('Chạm để nhập thêm', style: TextStyle(fontSize: 10, color: Colors.redAccent, fontStyle: FontStyle.italic)),
                              ]
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}