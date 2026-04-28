// lib/pages/duoc_si/don_hang/don_giao_hang.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import '../../../data/medicine_data.dart';
import '../../../data/customer_data.dart';
import 'qr_scanner_page.dart';
import 'chi_tiet_hoa_don_page.dart';

class DonGiaoHangWidget extends StatefulWidget {
  const DonGiaoHangWidget({Key? key}) : super(key: key);

  @override
  State<DonGiaoHangWidget> createState() => _DonGiaoHangWidgetState();
}

class _DonGiaoHangWidgetState extends State<DonGiaoHangWidget> {
  final ApiService _apiService = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  List<Map<String, dynamic>> _cart = [];
  String _currentPhone = '';
  final String _paymentMethod = 'Thanh toán khi nhận hàng';

  bool _isCheckingOut = false;
  bool _isAddingCustomer = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      String newPhone = _phoneController.text.trim();
      int existingIndex = globalCustomers.indexWhere((c) => c['phone'] == newPhone);
      setState(() { _currentPhone = newPhone; });

      if (existingIndex != -1) {
        String existingName = globalCustomers[existingIndex]['name'];
        String existingAddress = globalCustomers[existingIndex]['address'] ?? '';
        if (_nameController.text != existingName) _nameController.text = existingName;
        if (_addressController.text != existingAddress && existingAddress != 'Chưa cập nhật') {
          _addressController.text = existingAddress;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- HÀM THÊM VÀO GIỎ HÀNG ---
  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      int existingIndex = _cart.indexWhere((element) => element['name'] == item['name']);
      if (existingIndex >= 0) {
        _cart[existingIndex]['qty']++;
      } else {
        _cart.add({
          'name': item['name'],
          'price': (item['price'] as num).toDouble(),
          'qty': 1,
          'unit': item['unit'] ?? 'Đơn vị'
        });
      }
    });
  }

  // --- HÀM QUÉT MÃ VẠCH ---
  Future<void> _scanBarcode() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (scannedCode != null && scannedCode is String) {
      String cleanCode = scannedCode.trim();
      int index = globalMedicines.indexWhere((m) =>
      m['barcode'] == cleanCode || m['id'] == cleanCode
      );

      if (index != -1) {
        _addToCart(globalMedicines[index]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy thuốc mã: "$cleanCode"'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- HÀM TÌM THUỐC THỦ CÔNG (ĐÃ SỬA: CHỌN XONG SẼ ĐÓNG CỬA SỔ) ---
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập tên thuốc...',
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        displayedMedicines = globalMedicines
                            .where((m) => m['name'].toString().toLowerCase().contains(value.toLowerCase()))
                            .toList();
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
                          color: Colors.blue.shade50,
                          child: ListTile(
                            leading: const Icon(Icons.medication, color: Colors.blue),
                            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Tồn: ${item['stock']} | ${formatCurrency.format(item['price'])}'),
                            trailing: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
                            onTap: () {
                              _addToCart(item); // 1. Thêm vào giỏ
                              Navigator.pop(context); // 2. ĐÓNG CỬA SỔ TÌM KIẾM
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- HÀM XUẤT BILL & TẠO ĐƠN ---
  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống!')));
      return;
    }

    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();
    String address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ Tên, SĐT và Địa chỉ!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isCheckingOut = true);

    double total = _cart.fold(0, (sum, item) => sum + (item['qty'] * item['price']));

    final newOrderData = {
      'id': 'GH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'date': 'Hôm nay',
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'customerName': name,
      'phone': phone,
      'address': address,
      'total': total.toInt(),
      'status': 'Chờ xử lý',
      'type': 'Giao hàng',
      'paymentMethod': _paymentMethod,
      'items': List.from(_cart),
      'pointsPlus': (total / 10000).floor(),
    };

    await _apiService.createOrder(newOrderData);

    if (mounted) {
      setState(() => _isCheckingOut = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChiTietHoaDonPage(order: newOrderData)),
      );
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
        title: const Text('Tạo Đơn Giao Hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin người nhận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại (*)', prefixIcon: Icon(Icons.phone))),
                  const SizedBox(height: 12),
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên người nhận (*)', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 12),
                  TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng (*)', prefixIcon: Icon(Icons.location_on))),
                  if (showAddButton) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text('Lưu khách hàng', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
              child: Row(
                children: const [
                  Icon(Icons.local_shipping, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Hình thức: Thanh toán khi nhận hàng (COD)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                    onPressed: _showSearchMedicineBottomSheet,
                    icon: const Icon(Icons.search),
                    label: const Text('Tìm thủ công')
                )
              ],
            ),
            _cart.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Chưa có sản phẩm nào')))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return Card(
                  child: ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { if(item['qty'] > 1) item['qty']--; else _cart.removeAt(index); })),
                          Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => item['qty']++)),
                          const SizedBox(width: 10),
                          Text(formatCurrency.format(item['price'] * item['qty']), style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TỔNG THANH TOÁN:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Flexible(
                    child: Text(formatCurrency.format(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCheckingOut ? null : _checkout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isCheckingOut
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('TẠO ĐƠN GIAO HÀNG (COD)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}