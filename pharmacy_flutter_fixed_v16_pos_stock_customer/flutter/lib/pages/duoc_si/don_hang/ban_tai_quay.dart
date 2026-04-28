// lib/pages/duoc_si/don_hang/ban_tai_quay.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';

import '../../../data/medicine_data.dart';
import '../../../data/customer_data.dart';
import 'qr_scanner_page.dart';
import 'chi_tiet_hoa_don_page.dart';

class BanTaiQuayWidget extends StatefulWidget {
  final Map<String, dynamic>? initialPrescription;

  const BanTaiQuayWidget({Key? key, this.initialPrescription}) : super(key: key);

  @override
  State<BanTaiQuayWidget> createState() => _BanTaiQuayWidgetState();
}

class _BanTaiQuayWidgetState extends State<BanTaiQuayWidget> {
  final ApiService _apiService = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  List<Map<String, dynamic>> _cart = [];
  String _currentPhone = '';

  // PHƯƠNG THỨC THANH TOÁN: Mặc định là Tiền mặt (theo yêu cầu giống Long Châu)
  String _paymentMethod = 'Tiền mặt';

  bool _isCheckingOut = false;
  bool _isAddingCustomer = false;

  @override
  void initState() {
    super.initState();

    // Nếu chuyển từ màn hình quét đơn thuốc sang
    if (widget.initialPrescription != null) {
      _nameController.text = widget.initialPrescription!['patientName'] ?? '';
      _phoneController.text = widget.initialPrescription!['phone'] ?? '';
      _currentPhone = widget.initialPrescription!['phone'] ?? '';
      _cart = List<Map<String, dynamic>>.from(widget.initialPrescription!['medicines'] ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Tự động tìm tên khách hàng khi nhập số điện thoại
    _phoneController.addListener(() {
      String newPhone = _phoneController.text.trim();
      if (newPhone != _currentPhone) {
        int existingIndex = globalCustomers.indexWhere((c) => c['phone'] == newPhone);
        setState(() { _currentPhone = newPhone; });

        if (existingIndex != -1) {
          String existingName = globalCustomers[existingIndex]['name'];
          if (_nameController.text != existingName) {
            _nameController.text = existingName;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Quét mã vạch thuốc bằng camera
  Future<void> _scanBarcode() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (scannedCode != null && scannedCode is String) {
      String cleanCode = scannedCode.trim();
      int index = globalMedicines.indexWhere((m) {
        return m['barcode']?.toString().trim() == cleanCode ||
            m['id']?.toString().trim() == cleanCode;
      });

      if (index != -1) {
        _addToCart(globalMedicines[index]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Không tìm thấy thuốc! Mã: "$cleanCode"'),
                backgroundColor: Colors.red
            )
        );
      }
    }
  }

  // Lưu khách hàng mới vào hệ thống
  Future<void> _addCustomer() async {
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập SĐT và tên khách!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isAddingCustomer = true);

    final result = await _apiService.addCustomer({
      'name': name, 'phone': phone, 'address': 'Chưa cập nhật',
      'points': 0, 'level': 'Bạc', 'totalSpent': '0', 'lastVisit': 'Vừa xong',
    });

    if (mounted) setState(() => _isAddingCustomer = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.green));
    }
  }

  // Thêm sản phẩm vào giỏ hàng
  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      int existingIndex = _cart.indexWhere((element) => element['name'] == item['name']);
      if (existingIndex >= 0) _cart[existingIndex]['qty']++;
      else _cart.add({'name': item['name'], 'price': item['price'], 'qty': 1, 'serverId': item['serverId'], 'id': item['id']});
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${item['name']}'), duration: const Duration(seconds: 1)));
  }

  // Tìm kiếm thuốc thủ công bằng Bottom Sheet
  void _showSearchMedicineBottomSheet() {
    List<Map<String, dynamic>> displayedMedicines = List.from(globalMedicines);

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tìm kiếm thuốc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Nhập tên thuốc...', prefixIcon: const Icon(Icons.search, color: Colors.orange),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.orange), borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            displayedMedicines = globalMedicines.where((m) => m['name'].toString().toLowerCase().contains(value.toLowerCase())).toList();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: displayedMedicines.length,
                          itemBuilder: (context, index) {
                            final item = displayedMedicines[index];
                            return Card(
                              color: Colors.orange.shade50, elevation: 0, margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.medication, color: Colors.orange),
                                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Tồn: ${item['stock']} | ${formatCurrency.format(item['price'])}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.orange, size: 30),
                                  onPressed: () { _addToCart(item); Navigator.pop(context); },
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
          );
        }
    );
  }

  // Xử lý thanh toán đơn hàng
  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isCheckingOut = true);

    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();
    double total = _cart.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    int pointsEarned = (total / 10000).floor();

    // Cập nhật điểm khách hàng nếu có SĐT
    if (phone.isNotEmpty) {
      int existingIndex = globalCustomers.indexWhere((c) => c['phone'] == phone);
      if (existingIndex != -1) {
        globalCustomers[existingIndex]['points'] += pointsEarned;
        globalCustomers[existingIndex]['lastVisit'] = 'Vừa xong';
      }
    }

    // Tạo dữ liệu đơn hàng mới
    final newOrderData = {
      'id': 'DH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'date': 'Hôm nay', 'time': 'Vừa xong',
      'customerName': name.isEmpty ? 'Khách lẻ' : name,
      'phone': phone.isEmpty ? 'N/A' : phone,
      'total': total.toInt(),
      'status': 'Hoàn thành',
      'pointsPlus': pointsEarned,
      'type': 'Bán tại quầy',
      'paymentMethod': _paymentMethod,
      'items': List.from(_cart),
    };

    newOrderData['items'] = _cart.map((item) {
      final medicine = globalMedicines.cast<Map<String, dynamic>>().firstWhere(
        (m) => m['name'] == item['name'],
        orElse: () => <String, dynamic>{},
      );
      return {
        'name': item['name'],
        'qty': item['qty'],
        'price': item['price'],
        'serverId': item['serverId'] ?? medicine['serverId'],
        'id': item['id'] ?? medicine['id'],
      };
    }).toList();

    final result = await _apiService.createOrder(newOrderData);

    if (mounted) {
      setState(() => _isCheckingOut = false);
      if (result['success']) {
        // Chuyển thẳng sang trang Hóa đơn
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChiTietHoaDonPage(order: newOrderData)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result['message']}'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = _cart.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    bool customerExists = globalCustomers.any((c) => c['phone'] == _currentPhone);
    bool showAddButton = _currentPhone.isNotEmpty && !customerExists;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Bán Tại Quầy (POS)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange, elevation: 0,
        actions: [ IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode) ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin khách hàng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  TextField(
                      controller: _phoneController, keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: 'Số điện thoại', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Tên khách hàng', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))
                  ),
                  if (showAddButton) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity, height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _isAddingCustomer ? null : _addCustomer,
                        icon: _isAddingCustomer ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.person_add, color: Colors.white),
                        label: const Text('Lưu khách hàng mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sản phẩm đã chọn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: _showSearchMedicineBottomSheet, icon: const Icon(Icons.search, color: Colors.orange), label: const Text('Tìm thủ công', style: TextStyle(color: Colors.orange)))
              ],
            ),
            _cart.isEmpty
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('Giỏ hàng đang trống', style: TextStyle(color: Colors.grey))))
                : ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    // maxLines và overflow để tránh tràn pixel khi tên thuốc quá dài
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(formatCurrency.format(item['price'])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.grey), onPressed: () => setState(() { if (item['qty'] > 1) item['qty']--; else _cart.removeAt(index); })),
                        Text('${item['qty']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.orange), onPressed: () => setState(() => item['qty']++)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // CHỌN HÌNH THỨC THANH TOÁN (Logic giống Long Châu)
            const Text('Hình thức thanh toán', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPayMethodBtn('Tiền mặt', Icons.payments)),
                const SizedBox(width: 8),
                Expanded(child: _buildPayMethodBtn('Chuyển khoản', Icons.qr_code_scanner)),
              ],
            ),
            if (_paymentMethod == 'Chuyển khoản') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    const Text('Khách quét mã QR của bạn để thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/payment_qr_mb.png', height: 260, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.2))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TỔNG THANH TOÁN:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Flexible(
                    child: Text(formatCurrency.format(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange), textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                  onPressed: _isCheckingOut ? null : _checkout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isCheckingOut
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('XÁC NHẬN & IN HÓA ĐƠN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // WIDGET HỖ TRỢ CHỌN PHƯƠNG THỨC THANH TOÁN
  Widget _buildPayMethodBtn(String method, IconData icon) {
    bool isSelected = _paymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = method),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.orange : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                method,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}