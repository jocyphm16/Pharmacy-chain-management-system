// lib/tabs/duoc_si/products_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart'; // IMPORT API SERVICE

class ProductsTab extends StatefulWidget {
  const ProductsTab({Key? key}) : super(key: key);

  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final ApiService _apiService = ApiService(); // Khởi tạo Service
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  // Các biến quản lý State (Trạng thái)
  bool _isLoading = true; // Ban đầu vào màn hình là phải Loading
  List<Map<String, dynamic>> _medicines = []; // Danh sách thuốc lấy từ Server
  List<String> _categories = ['Tất cả']; // Danh sách danh mục

  @override
  void initState() {
    super.initState();
    _loadDataFromServer(); // Gọi API ngay khi mở màn hình
  }

  // HÀM GỌI API LẤY DỮ LIỆU
  Future<void> _loadDataFromServer() async {
    setState(() => _isLoading = true); // Bật vòng quay

    try {
      // Gọi API (chờ 1.5 giây)
      final data = await _apiService.fetchMedicines();

      // Bóc tách danh mục từ data
      Set<String> cats = {'Tất cả'};
      for (var m in data) {
        if (m['category'] != null) cats.add(m['category']);
      }

      // Cập nhật giao diện
      if (mounted) {
        setState(() {
          _medicines = data;
          _categories = cats.toList();
          _isLoading = false; // Tắt vòng quay
        });
      }
    } catch (e) {
      // Xử lý nếu API lỗi
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi tải dữ liệu từ máy chủ!')));
    }
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 20) return Colors.orange;
    return Colors.green;
  }

  String _getStockText(int stock) {
    if (stock == 0) return 'Hết hàng';
    if (stock <= 20) return 'Sắp hết ($stock)';
    return 'Còn hàng ($stock)';
  }

  // KHÔI PHỤC HỘP THOẠI XEM CHI TIẾT SẢN PHẨM CỦA BẠN
  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.medication, color: Colors.blue, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'Chưa cập nhật',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            'Mã SP: ${product['id'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 12),
                _buildDetailRow('Danh mục:', product['category'] ?? 'Khác'),
                _buildDetailRow('Đơn vị tính:', product['unit'] ?? 'N/A'),
                _buildDetailRow('Hạn sử dụng:', product['expiry'] ?? 'N/A'),
                _buildDetailRow('Giá bán:', formatCurrency.format(product['price'] ?? 0), isPrice: true),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Text('Tồn kho: ', style: TextStyle(color: Colors.black87, fontSize: 14)),
                      Text(
                        _getStockText(product['stock'] ?? 0),
                        style: TextStyle(
                            color: _getStockColor(product['stock'] ?? 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Nút Đóng
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.blue.shade400, width: 1.5),
                    ),
                    child: const Text('ĐÓNG', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(color: Colors.black87, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  color: isPrice ? Colors.blue : Colors.black87,
                  fontSize: isPrice ? 16 : 14,
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.normal
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LỌC DỮ LIỆU ĐÃ TẢI VỀ
    List<Map<String, dynamic>> filteredProducts = _medicines.where((product) {
      bool matchCategory = _selectedCategory == 'Tất cả' || product['category'] == _selectedCategory;
      String query = _searchQuery.toLowerCase();
      bool matchSearch = (product['id']?.toString().toLowerCase().contains(query) ?? false) ||
          (product['name']?.toString().toLowerCase().contains(query) ?? false);
      return matchCategory && matchSearch;
    }).toList();

    filteredProducts.sort((a, b) => (a['stock'] as int).compareTo(b['stock'] as int));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              'TRA CỨU SẢN PHẨM',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên thuốc, mã SP...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _categories.map((category) {
                        bool isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) => setState(() => _selectedCategory = category),
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                            backgroundColor: Colors.grey[100],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // KHÚC NÀY QUAN TRỌNG NHẤT: XỬ LÝ GIAO DIỆN LOADING
          Expanded(
            child: _isLoading
                ? const Center(
              // NẾU ĐANG TẢI: Hiển thị vòng quay loading
                child: CircularProgressIndicator(color: Colors.blue)
            )
                : filteredProducts.isEmpty
                ? const Center(child: Text('Không tìm thấy sản phẩm nào', style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                int stock = product['stock'] ?? 0;

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _showProductDetails(context, product), // GỌI LẠI HÀM HIỂN THỊ CHI TIẾT
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.medication_liquid, color: Colors.blue, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product['name'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Mã: ${product['id']} • ${product['category']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${formatCurrency.format(product['price'] ?? 0)} / ${product['unit']}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                    Text(
                                      _getStockText(stock),
                                      style: TextStyle(color: _getStockColor(stock), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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