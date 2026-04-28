// lib/tabs/duoc_si/orders_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/order_data.dart';
import '../../pages/duoc_si/don_hang/chi_tiet_hoa_don_page.dart'; // IMPORT TRANG HÓA ĐƠN

class OrdersTab extends StatefulWidget {
  const OrdersTab({Key? key}) : super(key: key);
  @override
  _OrdersTabState createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Hoàn thành', 'Chờ giao', 'Chờ xử lý', 'Đã hủy'];
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  Color _getStatusColor(String status) {
    if (status == 'Hoàn thành') return Colors.green;
    if (status == 'Đã hủy') return Colors.redAccent;
    if (status == 'Chờ giao') return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = globalOrders.where((order) {
      bool matchFilter = _selectedFilter == 'Tất cả' || order['status'] == _selectedFilter;
      String query = _searchQuery.toLowerCase();
      bool matchSearch = order['id'].toString().toLowerCase().contains(query) ||
          order['customerName'].toString().toLowerCase().contains(query) ||
          (order['phone'] != null && order['phone'].toString().toLowerCase().contains(query));
      return matchFilter && matchSearch;
    }).toList();

    return Column(
      children: [
        Container(
            width: double.infinity, color: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text('QUẢN LÝ ĐƠN HÀNG', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Tìm mã đơn, tên, SĐT...', prefixIcon: const Icon(Icons.search),
                      filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((filter) {
                    bool isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter), selected: isSelected,
                        onSelected: (selected) => setState(() => _selectedFilter = filter),
                        selectedColor: Colors.blue, labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Expanded(
          child: filteredOrders.isEmpty
              ? const Center(child: Text('Không tìm thấy đơn hàng nào'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              Color statusColor = _getStatusColor(order['status']);

              return Card(
                elevation: 1, margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  // ĐÃ SỬA: KHI BẤM VÀO SẼ CHUYỂN SANG TRANG CHI TIẾT HÓA ĐƠN
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChiTietHoaDonPage(order: order)),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.receipt_long, size: 28, color: Colors.blue),
                    ),
                    title: Text('${order['id']} - ${order['customerName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${order['time']} ${order['date']}'),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatCurrency.format(order['total']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(order['status'], style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}